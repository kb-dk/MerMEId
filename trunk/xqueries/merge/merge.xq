xquery version "1.0" encoding "UTF-8";


import module namespace loop="http://kb.dk/this/getlist" at "./merge_loop.xqm";

declare namespace xl="http://www.w3.org/1999/xlink";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";

declare namespace local="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $genre  := request:get-parameter("genre","") cast as xs:string;
declare variable $coll   := request:get-parameter("c",    "") cast as xs:string;
declare variable $query  := request:get-parameter("query","") cast as xs:string;
declare variable $page   := request:get-parameter("page", "1") cast as xs:integer;
declare variable $number := request:get-parameter("itemsPerPage","20") cast as xs:integer;
declare variable $publ   := request:get-parameter("published_only","");
declare variable $anthologies := request:get-parameter("anthologies","yes");
declare variable $stURI  := xs:anyURI(request:get-parameter("style","/storage/style/mei_to_html_print.xsl"));
declare variable $css    := xs:anyURI(request:get-parameter("css","/storage/style/mei_to_html_print.css"));
declare variable $database := request:get-parameter("db","/db/dcm");

declare variable $from     := ($page - 1) * $number + 1;
declare variable $to       :=  $from      + $number - 1;

declare function local:copy($element as element()) {
  element {node-name($element)}
  {
    for $attr in $element/@*
    where not(contains(node-name($attr),'style'))
     return $attr,
     for $child in $element/node()
     where not(contains(node-name($child),'script'))
     return 
       if ($child instance of element()) then 
	 local:copy($child)
       else 
	 $child
  }
};


let $params := 
<parameters>
   <param name="hostname" value="{request:get-header('HOST')}"/>
</parameters>

let $list := loop:getlist($database,$coll,$genre,$query)

return
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Merged documents</title>
<link rel="stylesheet" type="text/css" href="{$css}"/>
<script src="/editor/js/toggle_openness.js" type="text/javascript">
    /* js for foldable sections */
</script>
<script src="http://www.verovio.org/javascript/latest/verovio-toolkit-light.js" type="text/javascript">
    /* Include the Verovio toolkit for displaying incipits */
</script>
 <script type="text/javascript">
    /* Create the Verovio toolkit instance */
	var vrvToolkit = new verovio.toolkit();
</script>
</head>
<body>
{
  for $doc in $list
  let $html := 
  <div>
    { transform:transform($doc,$stURI,$params)//div[@id='main_content'] }
  </div>
  return 
  <div class="work">
    {local:copy($html)}
  </div>
}
</body>
</html>


