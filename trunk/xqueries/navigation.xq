xquery version "1.0" encoding "UTF-8";

import module namespace loop="http://kb.dk/this/getlist" at "./main_loop.xqm";
import module namespace  app="http://kb.dk/this/listapp" at "./list_utils.xqm";
import module namespace  filter="http://kb.dk/this/app/filter" at "./filter_utils.xqm";

declare namespace xl="http://www.w3.org/1999/xlink";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";
declare namespace m="http://www.music-encoding.org/ns/mei";

declare namespace local="http://kb.dk/this/app";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $genre  := request:get-parameter("genre","") cast as xs:string;
declare variable $coll   := request:get-parameter("c",    "") cast as xs:string;
declare variable $query  := request:get-parameter("query","");
declare variable $page   := request:get-parameter("page", "1") cast as xs:integer;
declare variable $number := request:get-parameter("itemsPerPage","20") cast as xs:integer;

declare variable $database := "/db/public";

declare variable $from     := ($page - 1) * $number + 1;
declare variable $to       :=  $from      + $number - 1;

declare variable $published_only := "";

declare function local:format-reference(
  $doc as node(),
  $pos as xs:integer ) as node() 

{
  let $class :=
    if($pos mod 2 = 1) then 
      "odd"
    else
      "even"

      let $ref   := 
      <p class="{$class}" xmlns="http://www.w3.org/1999/xhtml">
	<span class="composer">
	  {$doc//m:workDesc/m:work/m:titleStmt/m:respStmt/m:persName[@role='composer']}
	</span>
	<span>{app:view-document-reference($doc)}</span>
	<span>{app:get-edition-and-number($doc)}</span>
	<span>{util:document-name($doc)}</span>
      </p>
      return $ref
};




<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>
	{app:list-title()}
      </title>
      <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>

      <link rel="styleSheet" 
      href="/editor/style/navigation_style.css" 
      type="text/css"/>
      
      <script type="text/javascript" src="/editor/js/confirm.js">
      //
      </script>
      
      <script type="text/javascript" src="/editor/js/checkbox.js">
      //
      </script>
      
      <script type="text/javascript" src="/editor/js/publishing.js">
      //
      </script>

    </head>
    <body class="list_files">
      <div class="list_header">
      <h1>Navigation</h1>
      </div>

    {
      let $list := loop:getlist($database,$published_only,$coll,$genre,$query)
      return
      (<br clear="both" />,
      <div class="files_list">
        <div class="nav_bar">
          {app:navigation($list)}
        </div>
	<div style="width:30%;float:left;">
	{filter:print-filters($database,$published_only,$coll,$number,$genre,$query,$list)}
	</div>
	<div style="width:70%;float:left;">
          {
            for $doc at $count in $list[position() = ($from to $to)]
            return local:format-reference($doc,$count)
          }
	</div>
      </div>)
    }
    <div class="footer">
      <a href="http://www.kb.dk/dcm" title="DCM" 
      style="text-decoration:none;"><img 
           style="border: 0px; vertical-align:middle;" 
           alt="DCM Logo" 
           src="/editor/images/dcm_logo_small.png"/></a>
           2013 Danish Centre for Music Publication | The Royal Library, Copenhagen | <a name="www.kb.dk" id="www.kb.dk" href="http://www.kb.dk/dcm">www.kb.dk/dcm</a>
    </div>
  </body>
</html>
