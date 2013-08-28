xquery version "1.0" encoding "UTF-8";

import module namespace loop="http://kb.dk/this/getlist" at "./main_loop.xqm";
import module namespace  app="http://kb.dk/this/listapp" at "./list_utils.xqm";

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
  $pos as xs:integer ) as node() {

    let $class :=
      if($pos mod 2 = 1) then 
	"odd"
      else
	"even"

	let $ref   := 
	<tr class="result {$class}">
	  <td nowrap="nowrap">
	    {$doc//m:workDesc/m:work/m:titleStmt/m:respStmt/m:persName[@role='composer']}
	  </td>
	  <td>{app:view-document-reference($doc)}</td>
	  <td nowrap="nowrap">{app:get-edition-and-number($doc)} </td>
	</tr>
	return $ref
  };




      <html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	  <title>
	    {app:list-title()}
	  </title>
	  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
	  <link rel="styleSheet" 
	  href="/editor/style/list_style.css" 
	  type="text/css"/>
	  <link rel="styleSheet" 
	  href="/editor/style/xform_style.css" 
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
	    <img src="/editor/images/mermeid_30px_inv.png" 
            title=" " 
	    alt=" "/>
	  </div>
	  <div class="filter_bar">
	    <table class="filter_block">
	      <tr>
		<td class="label">Filter by: &#160;</td>
		<td class="label">Collection</td>
		<td class="label">Keywords</td>
	      </tr>
	      <tr>
		<td>&#160;</td>
		<td>
		
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
                    
          </td>
          <td>
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
          </td>
        </tr>
      </table>
    </div>
    {
      let $list := loop:getlist($database,$published_only,$coll,$query)
      return
      <div class="files_list">
        <div class="nav_bar">
          {app:navigation($list)}
        </div>
           
        <table border='0' cellpadding='0' cellspacing='0' class='result_table'>
          <tr>
            <th>Composer</th>
            <th>Title</th>
            <th>Collection</th>
          </tr>
          {
            for $doc at $count in $list[position() = ($from to $to)]
            return local:format-reference($doc,$count)
          }
        </table>
      </div>
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
