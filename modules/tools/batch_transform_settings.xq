xquery version "1.0" encoding "UTF-8";

declare namespace request="http://exist-db.org/xquery/request";

import module namespace config="https://github.com/edirom/mermeid/config" at "../config.xqm";

declare option exist:serialize "method=xml media-type=text/html;charset=UTF-8";

declare variable $coll   := request:get-parameter("coll",    "") cast as xs:string;
declare variable $query  := request:get-parameter("query","") cast as xs:string;
declare variable $xsl    := xs:anyURI(request:get-parameter("xsl",concat("http://",request:get-header('HOST'),"/storage/your-path-and-filename-here.xsl")));
declare variable $database := request:get-parameter("db", $config:data-root) cast as xs:string;


let $formpage :=
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Batch transform documents</title>
      <link rel="stylesheet" type="text/css" href="../../resources/css/dcm.css"/>
      <link rel="stylesheet" type="text/css" href="../../resources/css/public_list_style.css"/>
      <link rel="styleSheet" type="text/css" href="../../resources/css/list_style.css"/>
      <link rel="styleSheet" type="text/css" href="../../resources/css/xform_style.css"/>
    </head>
  <body class="list_files">
    <div id="all">
      <div id="main">
        <h1>Batch transform XML files in the database</h1>
            <form action="./batch_transform_list.xq" method="get" class="search" id="query_form" name="query_form" >

	      <p><strong>Collection</strong> (MerMEId file collection such as 'CNW')<br/>
	      <input style="color:black;" type="text" value="{$coll}"  name="coll"/><br/>&#160; 
	      </p>
	      <p><strong>Search query</strong> (filter by free text search, for instance a title)<br/>
	      <input type="text" value="{$query}" name="query" style="width: 30em;"/><br/>&#160; 
	      </p>
	      <p><strong>XSL style sheet URI</strong><br/> 
	      The XSLT style sheet to be used for the transformation. <br/>
	      <input type="text" value="{$xsl}" name="xsl" style="width: 30em;"/><br/>&#160; 
	      </p>
	      <p><strong>Database collection to be transformed</strong><br/>
	      The eXist database collection /db/apps/mermeid/data/ is where MerMEId stores your files by default. /db/apps/mermeid/data-public/ contains the files you have published with MerMEId.<br/>
	      <input type="text" value="{$database}" name="db" style="width: 30em;"/><br/>&#160; 
	      </p>
          <p>Hitting the 'Search files' button below will generate a list of files to be transformed (no transformation yet).</p>  
	      <p>Order list by
	          <select name="sortby">
     		    <option value="null,work_number">Work number</option>
    		    <option value="null,title">Title</option>
    	      </select>
    	      <br/>The sort order has no impact on the transformation. It affects only the list of files shown for your convenience. 
	      </p>
	      <p><input type="submit" value="Search files" /></p>
	    </form>
      </div>
    </div>
  </body>
</html>

return $formpage

