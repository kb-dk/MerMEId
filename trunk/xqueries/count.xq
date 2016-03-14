xquery version "1.0" encoding "UTF-8";

(: A simple tool for counting stuff :)

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

declare namespace local="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $what  := request:get-parameter("what","/meiHead") cast as xs:string;
declare variable $genre  := request:get-parameter("genre","") cast as xs:string;
declare variable $coll   := request:get-parameter("c",    "") cast as xs:string;
declare variable $query  := request:get-parameter("query","") cast as xs:string;
declare variable $published_only := request:get-parameter("published_only","") cast as xs:string;
declare variable $database := "/db/dcm";


<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Counting results</title>
      <link rel="stylesheet" type="text/css" href="/editor/style/dcm.css"/>
      <link rel="stylesheet" type="text/css" href="/editor/style/public_list_style.css"/>
      <link rel="styleSheet" type="text/css" href="/editor/style/list_style.css"/>
      <link rel="styleSheet" type="text/css" href="/editor/style/xform_style.css"/>
    </head>
    <body class="list_files">
    
      <div id="all">

      <div id="main">
         <div class="content_box">
           <h2>Counting: Potential no. of incipits</h2>
      {
      let $list := loop:getlist($database,$published_only,$coll,$genre,$query)
      return
      (
      <div class="files_list">
    	<div class="results">
    	   <table>
    	     <!-- not implemented yet - how do we evaluate $what string to a nodeset? 
    	     <tr>
    	       <td>Count what (relative to result set): </td>
    	       <td>{$what}</td>
     	     </tr>-->
    	     <tr>
    	       <td>Database: </td>
    	       <td>{$database}</td>
     	     </tr>
    	     <tr>
    	       <td>Collection: </td>
    	       <td>{$coll}</td>
     	     </tr>
    	     <!--<tr>
    	       <td>Genre: </td>
    	       <td>{$genre}</td>
     	     </tr>-->
    	     <tr>
    	       <td>Search terms: </td>
    	       <td>{$query}</td>
     	     </tr>
    	     <tr>
    	       <td>Published: </td>
    	       <td>{$published_only}</td>
     	     </tr>
    	     <tr>
    	       <td><b>Results: </b></td>
    	       <!-- hardcoded here: count what? -->
    	       <!-- to count potential number of incipits, use: fn:count($list//m:expression[not(.//m:expression)]) -->
    	       <td><b>{fn:count($list//m:expression[not(.//m:expression)])}</b></td>
     	     </tr>
    	   </table>
    	</div>
      </div>)
    }
    
    <p>New query:</p>
    <form method="get" id="status-selection" action="count.xq" >
    	   <table>
    	     <!--<tr>
    	       <td>Count what: </td>
    	       <td><input name="what" value="{$what}"/></td>
     	     </tr>-->
    	     <tr>
    	       <td>Collection: </td>
    	       <td>
    	         <select name="c">
                   <option value="">All collections</option>
                   <option value="HartW">HartW</option>
                   <option value="NWGW">NWGW</option>
                   <option value="CNW">CNW</option>
                   <option value="DCM">DCM</option>
                   <option value="GW">GW</option>
                   <option value="SchM">SchM</option>
                   <option value="TEST">TEST</option>
                 </select>
    	       </td>
     	     </tr>
    	     <!--<tr>
    	       <td>Genre: </td>
    	       <td><input name="genre" value="{$genre}"/></td>
     	     </tr>-->
    	     <tr>
    	       <td>Search terms: </td>
    	       <td><input name="query" value="{$query}"/></td>
     	     </tr>
    	     <tr>
    	       <td>Published: </td>
    	       <td>
    	         <select name="published_only">
    	           <option value="" selected="selected">All documents</option>
                   <option value="any">Published</option>
                   <option value="pending">Modified</option>
                   <option value="unpublished">Unpublished</option>
    	         </select>
    	       </td>
     	     </tr>
    	   </table>
    	   <input type="submit" value="Submit"/>
    </form>
    
    </div> 
    </div> 

    </div> 

  </body>
</html>
