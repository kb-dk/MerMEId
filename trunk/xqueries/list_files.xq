xquery version "1.0" encoding "UTF-8";

import module namespace loop="http://kb.dk/this/getlist" at "./main_loop.xqm";

declare namespace xl="http://www.w3.org/1999/xlink";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace app="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace ft="http://exist-db.org/xquery/lucene";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $coll   := request:get-parameter("c",    "") cast as xs:string;
declare variable $query  := request:get-parameter("query","");
declare variable $page   := request:get-parameter("page", "1") cast as xs:integer;
declare variable $number :=
request:get-parameter("itemsPerPage","20")   cast as xs:integer;

declare variable $from     := ($page - 1) * $number + 1;
declare variable $to       :=  $from      + $number - 1;

declare function app:format-reference(
	$doc as node(),
	$pos as xs:integer ) as node() {

	let $class :=
	if($pos mod 2 = 1) then 
	"odd"
	else
	"even"

	let $ref   := 
	<tr class="result {$class}">
	<td nowrap="nowrap">
	{$doc//m:workDesc/m:work/m:titleStmt/m:respStmt/m:persName[@role='composer']}
	</td>
	<td>{app:view-document-reference($doc)}</td>
	<td nowrap="nowrap">{app:get-edition-and-number($doc)} </td>
	<td>
	<a target="_blank"
        title="View XML source" 
        href="dcm/{util:document-name($doc)}">
	<img src="/editor/images/xml.gif" 
	alt="view source" 
	border="0"
        title="View source" />
	</a>
	</td>
	<td>{app:edit-form-reference($doc)}</td>
	<td>{app:delete-document-reference($doc)}</td>
	</tr>
	return $ref
};

declare function app:get-edition-and-number($doc as node() ) as xs:string* {

	let $c := 
	$doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"][1]/string()
	return ($c,$doc//m:meiHead/m:workDesc/m:work[1]/m:identifier[@type=$c]/string())

};

declare function app:view-document-reference($doc as node()) as node() {
	(: Beware: Hard coded reference here!!! :)
	let $ref := 
	<a  target="_blank"
        title="View" 
        href="/storage/present.xq?doc={util:document-name($doc)}">
	{$doc//m:workDesc/m:work[1]/m:titleStmt/m:title[string()][1]/string()}
	</a>
	return $ref
};

declare function app:edit-form-reference($doc as node()) as node() {
	(: 
	 Beware: Partly hard coded reference here!!!
	 It still assumes that the document resides on the same host as this
	 xq script but on port 80

	 The old form is called edit_mei_form.xml the refactored one starts on
	 edit-work-case.xml :)

	let $ref := 
	<a  title="Edit" 
        href="/orbeon/xforms-jsp/mei-form/?uri=http://{request:get-header('HOST')}/editor/forms/mei/edit-work-case.xml&amp;doc={util:document-name($doc)}">
	<img border="0" src="/editor/images/edit.gif" alt="edit" />
	</a>
	return $ref
};

declare function app:delete-document-reference($doc as node()) as node() {
	let $form-id := util:document-name($doc)
	let $form := 
	<form id="del{$form-id}" 
        action="http://{request:get-header('HOST')}/filter/delete/{util:document-name($doc)}"
	method="get" 
	style="display:inline;">
	
	<input 
	type="hidden" 
	name="file"
	value="{request:get-header('HOST')}/storage/dcm/{util:document-name($doc)}"
	title="file name"/>

	<input 
    	onclick="{fn:concat('show_confirm(&quot;del',$form-id,'&quot;,&quot;',$doc//m:workDesc/m:work/m:titleStmt/m:title[string()]/string()[1],'&quot;);return false;')}" 
	type="image" 
	src="/editor/images/delete.gif"  
	name="button"
	value="delete"
	title="Delete"/>
	</form>
	return  $form
};

declare function app:list-title() {

	let $title :=
	if(not($coll)) then
	"All documents"
	else
	($coll, " documents")

	return $title
};

declare function app:navigation( 
	$list as node()* 
	) as node()*
{

	let $total := fn:count($list/m:meiHead)
	let $uri   := "" (:request:get-effective-uri() cast as xs:string:)

	let $collection :=
	if(not($coll)) then
	""
	else
	if($coll="all") then
	""
	else
	fn:concat("&amp;c=",$coll)

	let $querypart :=
	if(not($query)) then ""
	else fn:concat("&amp;query=",$query)

	let $perpage  := fn:concat("&amp;itemsPerPage=",$number)
	let $nextpage := ($page+1) cast as xs:string

	let $next     :=
	if($from+$number<$total) then
	(element a {
			attribute rel   {"next"},
			attribute title {"Go to next page"},
			attribute href {
				fn:string-join((
						$uri,"?",
						"page=",
						$nextpage,
						$perpage,
						$collection,
						$querypart),"")
			},
			("Next page")
		},
		(" &gt;"))
	else
	("") 

	let $prevpage := ($page - 1) cast as xs:string

	let $previous :=
	if($from - $number + 1 > 0) then
	(("&lt; "),
		element a {
			attribute rel {"prev"},
			attribute title {"Go to previous page"},
			attribute href {
       				fn:string-join(
					($uri,"?","page=",$prevpage,$perpage,$collection,$querypart),"")},
			("Previous page")
		}
	)
	else
	("") 

	let $page_nav := for $p in 1 to 1 + ($total idiv $number)
	return 
	(if(not($page = $p)) then
		element a {
			attribute title {"Go to page ",xs:string($p)},
			attribute href {
       				fn:string-join(
					($uri,"?",
						"page=",xs:string($p),
						$perpage,
						$collection,
						$querypart),"")},
			($p)
		}
          else 
		element span {
			attribute style {"color:red;"},
			($p)
                }
	)

	let $links := ( 
		element table {
			element tr {
				element td {
					attribute style {"width:15%;text-align:left;"},
					$previous,"&#160;"},
				element td {
					attribute style {"width:70%;text-align:center;"},
					element p {
						element strong {
							$total," files"
						}
					},
					element p {$page_nav}},
				element td {
					attribute style {"width:15%;text-align:right;"},
					$next,"&#160;"}
			}
		}
	)
	return $links

};

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>
{app:list-title()}
</title>
<link rel="styleSheet" 
href="/editor/style/list_style.css" 
type="text/css"/>

<script type="text/javascript" src="/editor/js/confirm.js">
//
</script>

</head>
<body>
<div style="float:right;">
<a href="/editor/manual/" target="_blank"><img src="/editor/images/help.png" title="help" alt="help" border="0"/></a>
</div>
<img src="/editor/images/mermeid_30px.png" title="MerMEId - Metadata Editor and Repository for MEI Data" alt="MerMEId Logo"/>
<hr/>
<form action="" method="get" class="search">
<fieldset>
<input name="query"  value='{request:get-parameter("query","")}'/>
<input name="c"      value='{request:get-parameter("c","")}'    type='hidden' />
<input type="submit" value="Search"               />
<input type="submit" value="Clear" onclick="this.form.query.value='';this.form.submit();return true;"/>
<a class="help">?<span class="comment">Search is case insensitive. 
Search terms may be combined using boolean operators. Wildcards allowed. Some examples:<br/>
<span class="help_table">
<span class="help_example">
<span class="help_label">carl or nielsen</span>
<span class="help_value">Boolean OR (default)</span>
</span>                        
<span class="help_example">
<span class="help_label">carl and nielsen</span>
<span class="help_value">Boolean AND</span>
</span>
<span class="help_example">
<span class="help_label">"carl nielsen"</span>
<span class="help_value">Exact phrase</span>
</span>
<span class="help_example">
<span class="help_label">niels*</span>
<span class="help_value">Match any number of characters. Finds Niels, Nielsen and Nielsson</span>
</span>
<span class="help_example">
<span class="help_label">niels?n</span>
<span class="help_value">Match 1 character. Finds Nielsen and Nielson, but not Nielsson</span>
</span>
</span>
</span>
</a>
</fieldset>
</form>

<p>
{

	for $c in distinct-values(
		collection("/db/dcm")//m:seriesStmt/m:identifier[@type="file_collection"]/string()[string-length(.) > 0])
	let $querystring  := 
	if($query) then
	fn:string-join(
		("c=",
			$c,
			"&amp;query=",
			fn:escape-uri($query,true())),
		""
	)
	else
	fn:string-join(("c=",$c),"")

	return
	if(not($coll=$c)) then 
	<button type="submit" title="{$c}" onclick="location.href='?{$querystring}'; return false;">{$c}</button>
	else
	<button type="submit" title="{$c}" disabled="true">{$c}</button>
}
{

	let $get-uri := 
	if($query) then
	fn:string-join(("?query=",fn:escape-uri($query,true())),"")
	else
	"?c="

	let $link := 
	if($coll) then 
	<button type="submit" title="All collections" onclick="location.href='{$get-uri}'; return false;">All collections</button>
	else
	<button type="submit" title="All collections" disabled="true">All collections</button>
	return $link
}
</p> 
<h2>
{app:list-title()}
{
	<a title="Add new file" href="#" class="addLink" 
	onclick="location.href='/filter/new/'; return false;"><img 
	src="/editor/images/new.gif" alt="New file" border="0" /></a>
}
</h2>

{
	let $list := loop:getlist($coll,$query)
	return
	<div>
	{app:navigation($list)}

	<table border='0' cellpadding='0' cellspacing='0' class='result_table'>
	<tr><th>Composer</th><th>Title</th><th></th><th></th></tr>
	{
		
		for $doc at $count in $list[position() = ($from to $to)]
		return app:format-reference($doc,$count)

	}
	</table>
	</div>


}
</body>
</html>
