xquery version "1.0" encoding "UTF-8";

module  namespace  filter="http://kb.dk/this/app/filter";

declare namespace m="http://www.music-encoding.org/ns/mei";

declare variable $filter:page   := request:get-parameter("page", "1") cast as xs:integer;
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
  let $filter:=
    (<div class="filter_block">
    Filter by Collection
    <br/>
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
            	"&amp;query=",
            	fn:escape-uri($query,true())),
            	""
            	 )
               else
            	 concat("c=",$c,
            	 "&amp;published_only=",$published_only,
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
    </div>,
    <div class="filter_block">
      <form action="" method="get" class="search">
        <input name="query"  value='{request:get-parameter("query","")}'/>
        <input name="c"      value='{request:get-parameter("c","")}'    type='hidden' />
        <input name="published_only" value="{$published_only}" type='hidden' />
        <input name="itemsPerPage"  value='{$number}' type='hidden' />
        <input name="genre"  value='{$genre}' type='hidden' />
        <input type="submit" value="Search"               />
        <input type="submit" value="Clear" onclick="this.form.notbefore.value='';this.form.notafter.value='';this.form.genre.value='';this.form.query.value='';this.form.submit();return true;"/>
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
	<p>
	{

	  let $dates := 
	    for $date in $list//m:workDesc/m:work/m:history/m:creation/m:date
	      for $attr in $date/@notafter|$date/@isodate|$date/@notbefore
		return filter:get-date($attr/string())


	  let $notafter  := 
	    if(request:get-parameter("notafter","")) then
	      filter:get-date(request:get-parameter("notafter",""))
	    else
	      max($dates)

	  let $notbefore  := 
	    if(request:get-parameter("notbefore","")) then
	      filter:get-date(request:get-parameter("notbefore",""))
	    else
	      min($dates)

	  return 
            (<input name="notbefore" value="{$notbefore}"/>,
            <input name="notafter" value="{$notafter}" />
            )            
	}
	</p>
	<!-- #slider -->
    <table cellpadding="0" cellspacing="0" border="0">
        <tr>
            <td>
                <input type="text" name="notbefore" id="notbefore"/>
            </td>
            <td>
                <div class="slider" id="year_slider"></div>
            </td>
            <td>
                <input type="text" name="notafter" id="notafter"/>
            </td>
        </tr>
     </table>
     <!-- end #slider -->

     </form>
    </div>,
    <br clear="all"/>,
    <ul>
      {
	for $genre in 
	  distinct-values($list//m:workDesc/m:work/m:classification/m:termList/m:term/string())
	  where string-length($genre) > 0 and not ( contains($genre,"Vocal") or
	    contains($genre,"Instrumental") or contains($genre,"Stage") )  
	    return 
	    <li>
	      {
		filter:print-filtered-link(
		  $database,
		  $published_only,
		  $coll,
		  $number,
		  $query,
		  $genre),
		" (",
		filter:count-hits($genre,$list),
		")"
	      }
	    </li>
       }
    </ul>
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

declare function filter:get-date($date as xs:string) as xs:date
{
  let $xsdate :=
    if(string-length($date) = 4) then
      xs:date(string-join(($date,"01","01"),"-"))
    else
      xs:date($date)

  return $xsdate
};
