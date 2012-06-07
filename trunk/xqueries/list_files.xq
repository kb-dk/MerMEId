xquery version "1.0" encoding "UTF-8";

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

declare function app:format-reference(
  $doc as node(),
  $pos as xs:integer ) as node() {

  let $class :=
    if($pos mod 2 = 1) then 
      "odd"
    else
      "even"

  let $ref   := 
  <tr class="{$class}">
    <td>
    {$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:respStmt/m:persName[1]}
    </td>
    <td>{app:view-document-reference($doc)}</td>
    <td nowrap="nowrap">{app:get-edition-and-number($doc)}</td>
    <td>
      <a target="_blank"
         title="view XML source" 
         href="dcm/{util:document-name($doc)}">
	 <img src="/editor/images/xml.gif" 
	      alt="view source" 
	      border="0"
              title="view source" />
      </a>
    </td>
    <td>{app:edit-form-reference($doc)}</td>
    <td>{app:delete-document-reference($doc)}</td>
  </tr>
  return $ref
};

declare function app:get-edition-and-number($doc as node() ) as xs:string* {

  let $c := 
    $doc//m:seriesStmt/m:seriesStmt[@label="File collection"]/m:identifier/string()
  return ($c,$doc//m:meiHead/m:altId[@analog=$c]/string())

};

declare function app:view-document-reference($doc as node()) as node() {
  (: Beware: Hard coded reference here!!! :)
  let $ref := 
      <a  target="_blank"
          title="view" 
          href="/editor/scripts/get-exist.cgi?file=http://{request:get-header('HOST')}/storage/dcm/{util:document-name($doc)}">
	  {$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:title[1]/string()}
      </a>
  return $ref
};

declare function app:edit-form-reference($doc as node()) as node() {
  (: Beware: Hard coded reference here!!! :)
  (:http://disdev-01.kb.dk/orbeon/xforms-jsp/mei-form/?http://disdev-01.kb.dk/form/dcm&dir=http://disdev-01.kb.dk/storage/dcm&doc=cnw0292.xml:)
  let $ref := 
      <a  title="edit" 
          href="/orbeon/xforms-jsp/mei-form/?uri=http://{request:get-header('HOST')}/form/dcm/&amp;dir=http://{request:get-header('HOST')}/storage/dcm/&amp;doc={util:document-name($doc)}">
	<img border="0" src="/editor/images/edit.gif" alt="edit" />
      </a>
  return $ref
};

declare function app:delete-document-reference($doc as node()) as node() {
  let $form-id := util:document-name($doc)
  let $form := 
  <form id="del{$form-id}" 
        action="/editor/scripts/deletion-exist.cgi"  
	method="post" 
	style="display:inline;">
	
	<input 
	   type="hidden" 
	   name="file"
	   value="{request:get-header('HOST')}/storage/dcm/{util:document-name($doc)}"
	   title="file name"/>

	<input 
    	   onclick="{fn:concat('show_confirm(&quot;del',$form-id,'&quot;,&quot;',$doc//m:title[@type="main"][1]/string(),'&quot;);return false;')}" 
	   type="image" 
	   src="/editor/images/delete.gif"  
	   name="button"
	   value="delete"
	   title="Delete"/>
  </form>
  return  $form
};

declare function app:list-title() {
  let $coll := request:get-parameter("c","") 
  let $title :=
    if(not($coll)) then
      "All documents"
    else
      ($coll, " documents")

  return $title
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
  <h1>
    {app:list-title()}
  </h1>
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

      let $query := request:get-parameter("query","")
      let $coll  := request:get-parameter("c","")

      for $c in distinct-values(
	collection("/db/dcm")//m:seriesStmt/m:seriesStmt[@label="File collection"]/m:identifier/string()[string-length(.) > 0])
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
      let $coll    := request:get-parameter("c","") 
      let $query   := request:get-parameter("query","")
      let $get-uri := 
	if($query) then
	  fn:string-join(("?query=",fn:escape-uri($query,true())),"")
        else
	  ""

      let $link := 
	if($coll) then 
	  <button type="submit" title="All collections" onclick="location.href='{$get-uri}'; return false;">All collections</button>
	else
	  <button type="submit" title="All collections" disabled="true">All collections</button>
      return $link
    }
  </p>
  <p>
    {
    <button type="submit" title="New file" 
        onclick="location.href='/editor/scripts/new_file_exist.cgi'; return false;"><img 
        src="/editor/images/new.gif" alt="New file" border="0" /> Add new file
    </button>
    }
  </p>

  <table border='0' cellpadding='0' cellspacing='0'>
  <tr><th>Composer</th><th>Title</th><th></th><th></th></tr>
    {
      let $query := request:get-parameter("query","")
      let $coll  := request:get-parameter("c","")
      let $list  := 
	if($coll) then 
	  if($query) then
	    for $doc in collection("/db/dcm")/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:seriesStmt[@label="File collection"]/m:identifier/string()=$coll  and ft:query(.,$query)] 

	      order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:respStmt/m:persName[1]/string(),$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:title[1]/string()
	    return $doc 
	  else
	    for $doc in collection("/db/dcm")/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:seriesStmt[@label="File collection"]/m:identifier/string()=$coll] 
	      order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:respStmt/m:persName[1]/string(),$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:title[1]/string()
	    return $doc 
        else
	  if($query) then
            for $doc in collection("/db/dcm")/m:mei[ft:query(.,$query)]
	    order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:respStmt/m:persName[1]/string(),$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:title[1]/string()
	    return $doc
          else
            for $doc in collection("/db/dcm")/m:mei
	    order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:respStmt/m:persName[1]/string(),$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:title[1]/string()
	    return $doc

		 
      for $doc at $count in $list
      return app:format-reference($doc,$count)

    }
    </table>
  </body>
</html>
