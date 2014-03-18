xquery version "1.0" encoding "UTF-8";

import module namespace loop="http://kb.dk/this/getlist" at "./main_loop.xqm";
import module namespace app="http://kb.dk/this/listapp" at "./list_utils.xqm";
import module namespace filter="http://kb.dk/this/app/filter" at "./filter_utils.xqm";
import module namespace layout="http://kb.dk/this/app/layout" at "./cnw-layout.xqm";

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
declare variable $mode   := request:get-parameter("mode","") cast as xs:string;

declare variable $vocabulary := doc(concat("http://",request:get-header('HOST'),"/editor/forms/mei/model/keywords.xml"));

declare variable $database := "/db/public";

declare variable $from     := ($page - 1) * $number + 1;
declare variable $to       :=  $from      + $number - 1;

declare variable $published_only := "";

declare variable $sort-options :=
(<option value="null,work_number">Work number</option>,
<option value="null,title">Title</option>,
<option value="date,title">Year</option>
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
   {layout:head("Carl Nielsen Works (CNW)")}
    <body class="list_files">
    
      <div id="all">
      {layout:page-head("CNW","A Thematic Catalogue of Carl Nielsen&apos;s Works")}
      {layout:page-menu($mode)}

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
    </div> 
    </div> 

    {layout:page-footer($mode)}

    </div> 

  </body>
</html>
