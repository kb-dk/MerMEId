xquery version "1.0" encoding "UTF-8";

declare option exist:serialize "method=xml media-type=text/html;charset=UTF-8";

declare variable $mode   := request:get-parameter("mode","") cast as xs:string;
declare variable $genre  := request:get-parameter("genre","") cast as xs:string;
declare variable $coll   := request:get-parameter("c",    "") cast as xs:string;
declare variable $query  := request:get-parameter("query","") cast as xs:string;
declare variable $page   := request:get-parameter("page", "1") cast as xs:integer;
declare variable $number := request:get-parameter("itemsPerPage","20") cast as xs:integer;
declare variable $publ   := request:get-parameter("published_only","") cast as xs:string;
declare variable $anthologies := request:get-parameter("anthologies","yes");
declare variable $css    := request:get-parameter("css",concat("http://",request:get-header('HOST'),"/storage/style/mei_to_html.css")) cast as xs:string;
declare variable $stURI  := xs:anyURI(request:get-parameter("style",concat("http://",request:get-header('HOST'),"/storage/style/mei_to_html_print.xsl")));
declare variable $database := request:get-parameter("db","/db/dcm/") cast as xs:string;


let $formpage :=
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Merge documents</title>
      <link rel="stylesheet" type="text/css" href="/editor/style/dcm.css"/>
      <link rel="stylesheet" type="text/css" href="/editor/style/public_list_style.css"/>
      <link rel="styleSheet" type="text/css" href="/editor/style/list_style.css"/>
      <link rel="styleSheet" type="text/css" href="/editor/style/xform_style.css"/>
    </head>
  <body class="list_files">
    <div id="all">
      <div id="main">
        <h1>Merge multiple HTML documents</h1>
            <form action="./merge.xq"
	          method="get" 
		  class="search" 
		  id="query_form" name="query_form" >

	      <p><strong>Order by</strong><br/>
	      <select name="sortby">
		<option value="null,work_number">Work number</option>
		<option value="null,title">Title</option>
		<option value="date,title">Year</option>
	      </select><br/>&#160;</p>
	      <p><strong>Collection</strong> (MerMEId file collection such as 'CNW')<br/>
	      <input style="color:black;" type="text" value="{$coll}"  name="c"/><br/>&#160; 
	      </p>
	      <p><strong>Genre</strong> (filter by keywords)<br/>
	      <input type="text" value="{$genre}" name="genre" style="width: 30em;"/><br/>&#160; 
	      </p>
	      <p><strong>Search query</strong> (filter by free text search, for instance a title)<br/>
	      <input type="text" value="{$query}" name="query" style="width: 30em;"/><br/>&#160; 
	      </p>
	      <p><strong>XSL style sheet URI</strong><br/> 
	      The XSLT style sheet to be used for the transformation. MerMEId includes one named mei_to_html.xsl (the one used for the 
	      HTML preview from inside the editor) and another one named mei_to_html_print.xsl, which improves output for printing.<br/>
	      <input type="text" value="{$stURI}" name="style" style="width: 30em;"/><br/>&#160; 
	      </p>
	      <p><strong>eXist database</strong><br/>
	      The collection /db/dcm/ is where MerMEId stores your files by default. /db/public/ contains the files you have published with MerMEId.<br/>
	      <input type="text" value="{$database}" name="db" style="width: 30em;"/><br/>&#160; 
	      </p>
	      <p><strong>CSS style sheet</strong><br/> 
	      The CSS style sheet to design the output. MerMEId comes with two css variants: mei_to_html.css 
	      (which is the one used for the HTML preview from inside the editor) and mei_to_html_print.css
	       providing a simpler formatting which may be desirable for printing or further processing.<br/>
	      <input type="text" value="{$css}"  name="css" style="width: 30em;"/><br/> &#160;
	      </p>

	      <p><input type="submit" value="Generate" /></p>
	    </form>
      </div>
    </div>
  </body>
</html>

return $formpage

