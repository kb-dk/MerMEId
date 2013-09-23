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
   let $genres := 
      for $genre in 
	  distinct-values($doc//m:workDesc/m:work/m:classification/m:termList/m:term/string())
	  where string-length($genre) > 0   
	     return
	       $genre

   let $class := 
      for $genre in $genres
         return 
	         translate(translate($genre,' ,','_'),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')

   let $genre_boxes := 
      for $genre at $pos in $genres
         return 
            <span class="pos{$pos}">{$genre}</span>
            
      let $date_output :=
        if($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notbefore or $doc//m:workDesc/m:work/m:history/m:creation/m:date/@notafter) then
          substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notbefore,1,4) + '-' + substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notafter,1,4)
        else
          substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@isodate,1,4)

   let $ref   := 
      <div class="result_row">
	    <div class="composer">
	        {$doc//m:workDesc/m:work/m:titleStmt/m:respStmt/m:persName[@role='composer']/text()}
	        &#160;
	    </div>
	    <div class="date">&#160;{$date_output}</div>
        <div class="title">{app:view-document-reference($doc)}<!-- --></div>
        <div class="info_bar {$class}">
	      <span class="list_id">{app:get-edition-and-number($doc)}<!-- --></span>
	      <span class="genre">{$genre_boxes}<!-- --></span>
	     </div>
      </div>
   return $ref
};




<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>
	{app:list-title()}
      </title>
      <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
      
      <link type="text/css" href="/editor/style/dcm.css" rel="stylesheet" />
      <link type="text/css" href="/editor/style/cnw.css" rel="stylesheet" />


      <link rel="styleSheet" 
      href="/editor/style/public_list_style.css" 
      type="text/css"/>

      <!-- #slider -->
      <link href="/editor/jquery/jquery-ui-1.10.3/css/base/jquery-ui.css" 
         rel="stylesheet" 
         type="text/css"/>
      <link href="/editor/jquery/jquery-ui-1.10.3/css/style.css" 
         rel="stylesheet"  
         type="text/css"/>
      <!-- end #slider -->
      
      <script type="text/javascript" src="/editor/js/confirm.js">
      //
      </script>
      
      <script type="text/javascript" src="/editor/js/checkbox.js">
      //
      </script>
      
      <script type="text/javascript" src="/editor/js/publishing.js">
      //
      </script>
      
      <!-- #slider -->
      <script type="text/javascript" src="/editor/jquery/jquery-ui-1.10.3/js/jquery-1.9.1.js">
      //
      </script>
      <script type="text/javascript" src="/editor/jquery/jquery-ui-1.10.3/js/jquery-ui-1.10.3.custom.js">
      //
      </script>
      <script type="text/javascript" src="/editor/jquery/jquery-ui-1.10.3/slider.js">
      //
      </script>
      <!-- end #slider -->

      
    </head>
    <body class="list_files">
    
      <div id="all">
    
      <div id="header">
         <div class="kb_logo">
            <a href="http://www.kb.dk" title="Det Kongelige Bibliotek"><img 
             style="margin-top: -10px; border: 0px; vertical-align:middle;" title="Det Kongelige Bibliotek" 
             alt="KB Logo" src="/editor/images/kb_white.png"></img></a></div>
         <h1>Works</h1>
      </div> <!-- end header -->
      <div id="main">
         <div class="content_box">
    {
      let $list := loop:getlist($database,$published_only,$coll,$genre,$query)
      return
      (
      <div class="files_list">
    	<div class="filter">
    	{filter:print-filters($database,$published_only,$coll,$number,$genre,$query,$list)}
    	</div>
    	<div class="spacer"><div>&#160;</div></div>
    	<div class="results">
    	   <div class="nav_bar">
              {app:navigation($list)}
           </div>
           {
                for $doc at $count in $list[position() = ($from to $to)]
                return local:format-reference($doc,$count)
           }
    	</div>
      </div>)
    }
    </div> <!-- end content box -->
    </div> <!-- end main -->

    <div id="footer">
      <a href="http://www.kb.dk/dcm" title="DCM" 
      style="text-decoration:none;"><img 
           style="border: 0px; vertical-align:middle;" 
           alt="DCM Logo" 
           src="/editor/images/dcm_logo_small_white.png"/></a>
           2013 Danish Centre for Music Publication | The Royal Library, Copenhagen | <a name="www.kb.dk" id="www.kb.dk" href="http://www.kb.dk/dcm">www.kb.dk/dcm</a>
    </div> <!-- end footer -->
    </div> <!-- end all -->
  </body>
</html>
