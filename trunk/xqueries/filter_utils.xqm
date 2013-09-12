xquery version "1.0" encoding "UTF-8";

module namespace  filter="http://kb.dk/this/app/filter" at "./filter_utils.xqm";

declare namespace file="http://exist-db.org/xquery/file";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace xl="http://www.w3.org/1999/xlink";

declare variable $filter:coll   := request:get-parameter("c",    "") cast as xs:string;
declare variable $filter:query  := request:get-parameter("query","");
declare variable $filter:page   := request:get-parameter("page", "1") cast as xs:integer;
declare variable $filter:number :=
request:get-parameter("itemsPerPage","20")   cast as xs:integer;

declare variable $filter:from     := ($filter:page - 1) * $filter:number + 1;
declare variable $filter:to       :=  $filter:from      + $filter:number - 1;

declare variable $filter:published_only := 
request:get-parameter("published_only","") cast as xs:string;


declare function filter:print-filterse
  $database        as xs:string,
  $published_only  as xs:string,
  $coll            as xs:string,
  $query           as xs:string) as node()* 
{
  return
  <div class="filter_bar">
    <div class="filter_block">
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
    </div>
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
    </div>
  </div>
}
