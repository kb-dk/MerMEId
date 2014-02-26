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

declare variable $vocabulary := doc(concat("http://",request:get-header('HOST'),"/editor/forms/mei/model/keywords.xml"));

declare variable $database := "/db/public";

declare variable $from     := ($page - 1) * $number + 1;
declare variable $to       :=  $from      + $number - 1;

declare variable $published_only := "";

declare variable $sort-options :=
(<option value="null,work_number">Work number</option>,
<option value="null,title">Title</option>,
<option value="null,date">Year</option>,
<option value="date,title">Year, Title</option>
);



declare function local:format-reference(
  $doc as node(),
  $pos as xs:integer ) as node() 

{

   (: the first level 1 and 2 genre keywords are assumed to be the principal ones - all others are hidden :)
   let $genre1 := $doc//m:workDesc/m:work/m:classification/m:termList/m:term[contains(string-join($vocabulary//m:termList[@label='level1']/m:term," "),.) and normalize-space(.)!=''][1]/string()
   let $genre2 := $doc//m:workDesc/m:work/m:classification/m:termList/m:term[contains(string-join($vocabulary//m:termList[@label='level2']/m:term," "),.) and normalize-space(.)!=''][1]/string()
   let $class1 := translate(translate($genre1,' ,','_'),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')
   let $class2 := translate(translate($genre2,' ,','_'),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')
            
   let $date_output :=
     if($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notbefore!='' or $doc//m:workDesc/m:work/m:history/m:creation/m:date/@notafter!='') then
       concat(substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notbefore,1,4),'-',substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notafter,1,4))
     else
       substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@isodate,1,4)

   let $ref   := 
     <div class="result_row">
	    <div class="composer">{comment{$doc//m:workDesc/m:work/m:titleStmt/m:respStmt/m:persName[@role='composer']/text()}}&#160;</div>
	    <div class="date">&#160;{$date_output}</div>
        <div class="title">
	      {app:public-view-document-reference($doc)}{" "}
	    </div>
        <div class="info_bar {$class2}">
	      <span class="list_id">
	        {app:get-edition-and-number($doc)}{" "}
	      </span>
	      <span class="genre">
	      {
	        if (string-length($genre1)>0) then 
	           <span class="pos1">{$genre1}</span>
	        else ""
	      }
	      {
	        if (string-length($genre2)>0) then 
	           <span class="pos2">{$genre2}</span>
	        else ""
	      }
	      </span>
	    </div>
      </div>
   return $ref

(: the following lists ALL genre keywords instead :)
(:   let $genres := 
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
        if($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notbefore!='' or $doc//m:workDesc/m:work/m:history/m:creation/m:date/@notafter!='') then
          concat(substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notbefore,1,4),'-',substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notafter,1,4))
        else
          substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@isodate,1,4)

   let $ref   := 
      <div class="result_row">
	<div class="composer">{comment{$doc//m:workDesc/m:work/m:titleStmt/m:respStmt/m:persName[@role='composer']/text()}}&#160;</div>
	<div class="date">&#160;{$date_output}</div>
        <div class="title">
	  {app:public-view-document-reference($doc)}{" "}
	</div>
        <div class="info_bar {$class}">
	  <span class="list_id">
	    {app:get-edition-and-number($doc)}{" "}
	  </span>
	  <span class="genre">
	    {$genre_boxes}{" "}
	  </span>
	</div>
      </div>
   return $ref  :)
};

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Carl Nielsen Works (CNW)</title>
      
<!-- 
generated title disabled 
-->

<!-- 
<title>{app:list-title()}</title>
 -->
      
      <meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
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
				id="KBLogo"
				title="Det Kongelige Bibliotek" 
				alt="KB Logo" src="/editor/images/kb_white.png"/><img
				id="KBLogo_print"
				title="Det Kongelige Bibliotek" 
				alt="KB Logo" src="/editor/images/kb.png"/></a>
		</div>
		<h1>CNW</h1>
		<h2>A Thematic Catalogue of Carl Nielsen&apos;s Works</h2>
      </div> <!-- end header -->
      <div id="menu">
             <a href="index.html">Home</a> 
             <a href="introduction.html">Introduction</a>
             <a href="navigation.xq" class="selected">Catalogue</a> 
      </div> <!-- end menu -->

      <div id="main">
         <div class="content_box">
    {
      let $list := loop:getlist($database,$published_only,$coll,$genre,$query)
      return
      (
      <div class="files_list">
    	<div class="filter">
    	{filter:print-filters($database,$published_only,$coll,string($number),$genre,$query,$list)}
    	</div>
    	<div class="spacer"><div>&#160;</div></div>
    	<div class="results">
    	   <div class="nav_bar">
              {app:navigation($sort-options,$list)}
           </div>
           <div class="filter_elements">
              {filter:filter-elements()}
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
		  src="/editor/images/dcm_logo_small_white.png"
		  id="dcm_logo"/><img 
		  style="border: 0px; vertical-align:middle;" 
		  alt="DCM Logo" 
		  src="/editor/images/dcm_logo_small.png"
		  id="dcm_logo_print"
		/></a>
        2013 Danish Centre for Music Publication | The Royal Library, Copenhagen | <a name="www.kb.dk" id="www.kb.dk" href="http://www.kb.dk/dcm">www.kb.dk/dcm</a>
    </div> <!-- end footer -->
    </div> <!-- end all -->
  </body>
</html>
