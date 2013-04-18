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
declare namespace ht="http://exist-db.org/xquery/httpclient";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $coll   := request:get-parameter("c",    "") cast as xs:string;
declare variable $query  := request:get-parameter("query","");
declare variable $page   := request:get-parameter("page", "1") cast as xs:integer;
declare variable $number :=
request:get-parameter("itemsPerPage","20")   cast as xs:integer;

declare variable $from     := ($page - 1) * $number + 1;
declare variable $to       :=  $from      + $number - 1;

declare function app:is-published($file as xs:string) as node() {
	let $uri := concat("http://localhost:8080/rest/db/",$file) cast as xs:anyURI
	let $head:=ht:head($uri, false(), () )
	return $head
};

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
	<td>{app:get-publication-reference($doc)}</td>
	<td>{app:delete-document-reference($doc)}</td>
	</tr>
	return $ref
};

declare function app:pass-as-hidden() as node()* {
	let $inputs :=
	(<input name="c"            type="hidden" value="{$coll}"   />,
	<input name="query"        type="hidden" value="{$query}"  />,
	<input name="page"         type="hidden" value="{$page}"   />,
	<input name="itemsPerPage" type="hidden" value="{$number}" />)
	return $inputs
};

declare function app:get-publication-reference($doc as node() )  as node()* 
        {
	let $doc-name:=util:document-name($doc)
	let $color_style := 
	if(doc-available(concat("public/",$doc-name))) then
	(
		let $public_hash:=util:hash(doc(concat("public/",$doc-name)),'md5')
		let $dcm_hash:=util:hash($doc,'md5')
		return
		if($dcm_hash=$public_hash) then
		"publishedIsGreen"
		else
		"pendingIsYellow"
	)
	else
	"unpublishedIsRed"

	let $form:=
	<form id="formsourcediv{$doc-name}"
	      action="./list_files.xq" 
	      method="post" style="display:inline;">

	   <div id="sourcediv{$doc-name}"
 	      style="display:inline;">

             <input id="source{$doc-name}" 
	          type="hidden" 
	          value="publish" 
	          name="dcm/{$doc-name}" 
	          title="file name"/>

	     <label class="{$color_style}" for='checkbox{$doc-name}'>
                  <input id='checkbox{$doc-name}'
	          onclick="add_publish('sourcediv{$doc-name}',
	                               'source{$doc-name}',
	                               'checkbox{$doc-name}');" 
	          type="checkbox" 
	          name="button" 
	          value="" 
	          title="publish"/></label>

	</div>
	</form>
	return $form
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

	let $form-id := util:document-name($doc)
	let $ref := 
	<form id="edit{$form-id}" 
        action="/orbeon/xforms-jsp/mei-form/" style="display:inline;" method="get">

	<input type="hidden"
	       name="uri"
	       value="http://{request:get-header('HOST')}/editor/forms/mei/edit-work-case.xml" />
	<input type="hidden"
	       name="doc"
	       value="{util:document-name($doc)}" />
	<input type="image"
	       title="Edit" 
	       src="/editor/images/edit.gif" 
	       alt="Edit" />
	{app:pass-as-hidden()}
	</form>

	return $ref

};

declare function app:delete-document-reference($doc as node()) as node() {
	let $form-id := util:document-name($doc)
	let $form := 
	<form id="del{$form-id}" 
        action="http://{request:get-header('HOST')}/filter/delete/dcm/{util:document-name($doc)}"
	method="post" 
	style="display:inline;">

	{app:pass-as-hidden()}
	
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
						},
						(<form action="./list_files.xq" style="display:inline;">
						<select name="itemsPerPage" onchange="this.form.submit();return true;"> 
						{(
								element option {attribute value {"10"},
								      if($number=10) then 
								      attribute selected {"selected"}
								      else
								      "",
								      "10 per page"},
								element option {attribute value {"20"},
								      if($number=20) then 
								      attribute selected {"selected"}
								      else
								      "",
								      "20 per page"},
								element option {attribute value {"50"},
								      if($number=50) then 
								      attribute selected {"selected"}
								      else
								      "",
								      "50 per page"},
								element option {attribute value {"100"},
								      if($number=100) then 
								      attribute selected {"selected"}
								      else
								      "",
								      "100 per page"},
								element option {attribute value {"5000"},
								      if($number=5000) then 
								      attribute selected {"selected"}
								      else
								      "",
								      "all on one page"}
								)}
						</select>

						<input type="hidden" name="c"  value="{$coll}"/>
						<input type="hidden" name="query" value="{$query}"/>
						<input type="hidden" name="page" value="1" />

						</form>)
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
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
<link rel="styleSheet" 
href="/editor/style/list_style.css" 
type="text/css"/>
<link rel="styleSheet" 
href="/editor/style/xform_style.css" 
type="text/css"/>
<link rel="styleSheet" 
href="/editor/style/front_page.css" 
type="text/css"/>
<link rel="styleSheet" 
href="/editor/style/manual.css" 
type="text/css"/>

<script type="text/javascript" src="/editor/js/confirm.js">
//
</script>

<script type="text/javascript" src="/editor/js/checkbox.js">
//
</script>

</head>
<body class="list_files">
<div class="main">
<div class="manual_header">
<div style="float:right;">
<a href="/editor/manual/" target="_blank"><img src="/editor/images/help.png" title="Help - opens the manual in a new window or tab" alt="Help" border="0"/></a>
</div>
<img src="/editor/images/mermeid_30px.png" title="MerMEId - Metadata Editor and Repository for MEI Data" alt="MerMEId Logo"/>
</div>
<form action="" method="get" class="search">
<input name="query"  value='{request:get-parameter("query","")}'/>
<input name="c"      value='{request:get-parameter("c","")}'    type='hidden' />
<input name="itemsPerPage"  value='{$number}' type='hidden' />
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
</form>

<p>
{

	for $c in distinct-values(
		collection("/db/dcm")//m:seriesStmt/m:identifier[@type="file_collection"]/string()[string-length(.) > 0])
	let $querystring  := 
	if($query) then
	fn:string-join(
		("c=",$c,
		"&amp;itemsPerPage=",$number cast as xs:string,	
		"&amp;query=",
		fn:escape-uri($query,true())),
		""
	)
	else
	fn:string-join(("c=",$c,"&amp;itemsPerPage=",$number cast as xs:string),"")

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

<br style="clear:both;"/>

<form method="post" action="./publish.xq" >
<div id="publish">

<input type="submit" 
	       name="publish" 
	       value="publish selected files" />

{app:pass-as-hidden()}

<input 
	    onclick="check_all();return false;"
	    type="button" 
	    name="publish" 
	    value="check all records" />

<input 
	    onclick="un_check_all();return false;"
	    type="button" 
	    name="publish" 
	    value="&quot;uncheck&quot; all records" />

	
</div>
</form>


<div class="files_list" style="width:100%">
<h2>
{app:list-title()}
{
	<a title="Add new file" href="#" class="addLink" 
	onclick="location.href='/filter/new/dcm/'; return false;"><img 
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
</div>
</div>
<div class="footer">
           <a href="http://www.kb.dk/dcm" title="DCM"><img style="border: 0px; vertical-align:middle;" alt="DCM Logo" src="/editor/images/dcm_logo_small.png"/></a>
            2013 Danish
              Centre for Music Publication | The Royal Library, Copenhagen | <a name="www.kb.dk" id="www.kb.dk" href="http://www.kb.dk/dcm">www.kb.dk/dcm</a>
</div>

</body>
</html>
