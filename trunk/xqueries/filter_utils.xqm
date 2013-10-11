xquery version "1.0" encoding "UTF-8";

module  namespace  filter="http://kb.dk/this/app/filter";

declare namespace m="http://www.music-encoding.org/ns/mei";

declare variable $filter:sortby := request:get-parameter("sortby", "") cast as xs:string;
declare variable $filter:page   := request:get-parameter("page",   "1") cast as xs:integer;
declare variable $filter:number := request:get-parameter("itemsPerPage","20") cast as xs:integer;
declare variable $filter:uri    := "";

declare function filter:print-filters(
  $database        as xs:string,
  $published_only  as xs:string,
  $coll            as xs:string,
  $number          as xs:integer,
  $genre           as xs:string,
  $query           as xs:string,
  $list as node()*) as node()* 
{
  let $notafter  := request:get-parameter("notafter","1931")
  let $notbefore := request:get-parameter("notbefore","1880")

  let $filter:=
    ( 
    (: Collection filter disabled :)
    (:<div class="filter_block">
    <span class="label">Collection </span>
    <select onchange="location.href=this.value; return false;">
      {
        for $c in distinct-values(
          collection($database)//m:seriesStmt/m:identifier[@type="file_collection"]/string()[string-length(.) > 0 ])
          let $querystring  := 
            if($query) then
              fn:string-join(
            	("c=",$c,
            	"&amp;published_only=",$published_only,
            	"&amp;itemsPerPage=",$number cast as xs:string,	
            	"&amp;sortby=",$filter:sortby,
            	"&amp;query=",
            	fn:escape-uri($query,true())),
            	""
            	 )
               else
            	 concat("c=",$c,
            	 "&amp;published_only=",$published_only,
            	"&amp;sortby=",$filter:sortby,
            	 "&amp;itemsPerPage="  ,$number cast as xs:string)
            	 return
            	   if(not($coll=$c)) then 
            	   <option value="?{$querystring}">{$c}</option>
            	 else
            	 <option value="?{$querystring}" selected="selected">{$c}</option>
               }
	       {
            	 let $get-uri := 
            	   if($query) then
            	     fn:string-join(("?published_only=",$published_only,"&amp;query=",fn:escape-uri($query,true())),"")
            	   else
            	     concat("?c=&amp;published_only=",$published_only)
            
  	         let $link := 
            	   if($coll) then 
            	   <option value="{$get-uri}">All collections</option>
            	 else
            	 <option value="{$get-uri}" selected="selected">All collections</option>
            	 return $link
               }
    </select>
    </div>, :)
    <div class="filter_block">
      <form action="" method="get" class="search" id="query_form" name="query_form">
        <div class="label">Keywords</div>
        <input name="query"  value='{request:get-parameter("query","")}' id="query_input"/>
        <input name="c"      value='{request:get-parameter("c","")}'    type='hidden' />
        <input name="published_only" value="{$published_only}" type='hidden' />
        <input name="itemsPerPage"  value='{$number}' type='hidden' />
        <input name="sortby"  value='{$filter:sortby}' type='hidden' />
        <input name="genre"  value='{$genre}' type='hidden' />
        <input name="notbefore" value='{request:get-parameter("notbefore","")}' type='hidden' />
        <input name="notafter" value='{request:get-parameter("notafter","")}' type='hidden' />
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
            <span class="help_value">Match any number of characters. Finds Niels, Nielsen and Nielsson<br/>
            (use only at end of word)
            </span>
          </span>
          <span class="help_example">
            <span class="help_label">niels?n</span>
            <span class="help_value">Match 1 character. Finds Nielsen and Nielson, but not Nielsson</span>
          </span>
        </span>
      </span>
      </a>
	  <div class="search_submit">
         <input type="submit" value="Search" id="search_submit"/>
      </div>
    </form>
    <form action="" method="get" class="search" id="year_form" name="year_form">
        <div class="label">Year of composition</div>    
	    <table cellpadding="0" cellspacing="0" border="0">
            <tr>
        		<td style="padding-left: 0;">
                    <input id="notbefore" name="notbefore" value="{$notbefore}" onblur="setYearSlider()"/>
        		</td>
        		<td>
                    <div class="slider" id="year_slider"><!-- --></div>
        		</td>
        		<td>
                    <input id="notafter" name="notafter" value="{$notafter}" onblur="setYearSlider()"/>
        		</td>
            </tr>
	    </table>
	    <div class="search_submit">
          <input type="submit" value="Search" id="year_submit"/>
        </div>
        <input name="query"  value='{request:get-parameter("query","")}' type="hidden"/>
        <input name="c"      value='{request:get-parameter("c","")}'    type='hidden' />
        <input name="published_only" value="{$published_only}" type='hidden' />
        <input name="itemsPerPage"  value='{$number}' type='hidden' />
        <input name="sortby"  value='{$filter:sortby}' type='hidden' />
        <input name="genre"  value='{$genre}' type='hidden' />
     </form>     
    </div>,
    <div class="genre_filter filter_block">
      {

        let $vocabulary := doc("http://disdev-01.kb.dk/editor/forms/mei/model/keywords.xml")
        (:distinct-values($list//m:workDesc/m:work/m:classification/m:termList/m:term/string()):)
        
(:	for $genre in $vocabulary/m:classification/m:termList[@label="level2"]/m:term/string()  :)
	  (:for $genre in 
	  distinct-values($list//m:workDesc/m:work/m:classification/m:termList/m:term/string())
	  where string-length($genre) > 0 and not ( contains($genre,"Vocal") or
	    contains($genre,"Instrumental") or contains($genre,"Stage") )  :)
(:	    let $num := filter:count-hits($genre,$list)
	    return 
              if($num > 0) then (
	    <div class="genre_filter_row">
	              
            <span class="genre_indicator {translate(translate($genre,' ,','_'),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')}">&#160;</span>
        
	      {
		filter:print-filtered-link(
		  $database,
		  $published_only,
		  $coll,
		  $number,
		  $query,
		  $genre),
		" (",$num,")"
	      }
	    </div> ) else ()   :)

	for $genre in $vocabulary/m:classification/m:termList[@label="level1" or @label="level2"]/m:term/string()
	  (:for $genre in 
	  distinct-values($list//m:workDesc/m:work/m:classification/m:termList/m:term/string())
	  where string-length($genre) > 0 and not ( contains($genre,"Vocal") or
	    contains($genre,"Instrumental") or contains($genre,"Stage") )  :)
	    let $num := filter:count-hits($genre,$list)
	    let $link := filter:print-filtered-link(
		  $database,
		  $published_only,
		  $coll,
		  $number,
		  $query,
		  $genre)		  
 
	    return 
          if($num > 0) then (
	           if ($vocabulary/m:classification/m:termList[m:term/string()=$genre]/@label="level2")
	           then (
	              <div class="genre_filter_row level2">
                     <span class="genre_indicator {translate(translate($genre,' ,','_'),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')}">&#160;</span>
                     &#160; {$link} 
                     <span class="num"> ({$num})</span>
                  </div>
               )
               else (
                  <div class="genre_filter_row level1">{$link} 
                     <span class="num"> ({$num})</span>
                  </div>
               )
               
	      ) else ()
       }
       <span>&#160;</span>
    </div>
    )
    return $filter
};


declare function filter:count-hits(
  $term as xs:string,
  $list as node()*) as xs:integer* 
{
  let $number :=
  for $count in count($list//m:workDesc[contains(m:work/m:classification/m:termList/m:term/string(),$term) ])
    return $count
  return $number
};

declare function filter:filter-elements() 
{
  let $notafter  := request:get-parameter("notafter","")
  let $notbefore := request:get-parameter("notbefore","")
  let $query := request:get-parameter("query","")
  let $genre := request:get-parameter("genre","")
  let $this_uri := fn:concat($filter:uri,"?",request:get-query-string())
 
  let $year_block :=
      if($notbefore or $notafter) then
       <a class="filter_element"
           href="{fn:replace(fn:replace($this_uri,'notbefore=\d*','notbefore='),'notafter=\d*','notafter=')}">
           Year of composition: {$notbefore}–{$notafter} 
       </a>
    else
       ""
  let $query_block :=
      if($query) then
       <a class="filter_element"
           href="{fn:replace($this_uri,'query=[^&amp;]+','query=')}">
           Keyword(s): {$query} 
       </a>
    else
       ""
  let $genre_block :=
      if($genre) then
       <a class="filter_element" 
           href="{fn:replace($this_uri,'genre=[^&amp;]+','genre=')}">
           Genre: {$genre} 
       </a>
    else
       ""
  let $reset_block :=
      if($genre_block or $year_block or $query_block) then
       <a class="filter_element reset" 
           href="{fn:concat($filter:uri,'?itemsPerPage=',request:get-parameter("itemsPerPage",""),'&amp;sortby=',request:get-parameter("sortby",""))}">
           Reset all
       </a> 
    else
       ""
  let $clear :=
      <br style="clear:both"/>
  return ($year_block, $query_block, $genre_block, $reset_block, $clear)
};



declare function filter:print-filtered-link(
  $database        as xs:string,
  $published_only  as xs:string,
  $coll            as xs:string,
  $number          as xs:integer,
  $query           as xs:string,
  $term            as xs:string) as node()*
{
  let $link := (
    element a 
    {
      attribute title {"Filter with ",$term},
      attribute href {
	fn:string-join((
	  $filter:uri,"?",
	  "page=",1,
	  "&amp;itemsPerPage=",$number,
	  "&amp;sortby=",request:get-parameter("sortby",""),
	  "&amp;c=",$coll,
	  "&amp;published_only=",$published_only,
	  "&amp;query=",$query,
	  "&amp;notbefore=",request:get-parameter("notbefore",""),
	  "&amp;notafter=",request:get-parameter("notafter",""),
	  "&amp;genre=",fn:escape-uri($term,true())),"")},
	  $term
    }
    )
    return $link
};

declare function filter:get-date($date as xs:string) as xs:integer
{
  let $xsdate :=
      substring($date,1,4)

  return $xsdate
};
