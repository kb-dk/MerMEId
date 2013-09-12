xquery version "1.0" encoding "UTF-8";

module  namespace  filter="http://kb.dk/this/app/filter";

declare namespace m="http://www.music-encoding.org/ns/mei";

declare function filter:print-filters(
  $database        as xs:string,
  $published_only  as xs:string,
  $coll            as xs:string,
  $number          as xs:integer,
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
          collection($database)//m:seriesStmt/m:identifier[@type="file_collection"]/string()[string-length(.) > 0])
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
      </form>
    </div>,
    <br clear="all"/>,
    <ul>{
    for $genre in distinct-values($list//m:workDesc/m:work/m:classification/m:termList/m:term/string())
      let $entry := <li>{$genre}</li>
      return $entry
    }</ul>
    )
    return $filter
};
