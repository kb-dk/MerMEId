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

declare namespace local="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $genre  := request:get-parameter("genre","") cast as xs:string;
declare variable $coll   := request:get-parameter("c",    "") cast as xs:string;
declare variable $query  := request:get-parameter("query","") cast as xs:string;
declare variable $page   := request:get-parameter("page", "1") cast as xs:integer;
declare variable $number := request:get-parameter("itemsPerPage","20") cast as xs:integer;

declare variable $database := "/db/dcm";

declare variable $from     := ($page - 1) * $number + 1;
declare variable $to       :=  $from      + $number - 1;

declare variable $sort-options :=
(<option value="person,title">Composer,Title</option>,
<option value="person,date">Composer, Year</option>,
<option value="person,work_number">Composer,Work number</option>,
<option value="date,person">Year, Composer</option>,
<option value="date,title">Year, Title</option>,
<option value="null,work_number">Work number</option>
);


declare variable $published_only := 
request:get-parameter("published_only","") cast as xs:string;

declare function local:format-reference(
  $doc as node(),
  $pos as xs:integer ) as node() {

    let $class :=
      if($pos mod 2 = 1) then 
	"odd"
      else
	"even"

      let $date_output :=
	if($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notbefore!='' or $doc//m:workDesc/m:work/m:history/m:creation/m:date/@notafter!=''
	  or $doc//m:workDesc/m:work/m:history/m:creation/m:date/@startdate!='' or $doc//m:workDesc/m:work/m:history/m:creation/m:date/@enddate!='') then
	  concat(substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notbefore,1,4),
	  substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@startdate,1,4),
	  '-',
	  substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@enddate,1,4),
	  substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@notafter,1,4))
        else
          substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/@isodate,1,4)


	let $ref   := 
	<tr class="result {$class}">
	  <td nowrap="nowrap">
	    {$doc//m:workDesc/m:work/m:titleStmt/m:respStmt/m:persName[@role='composer']}
	  </td>
	  <td>{app:view-document-reference($doc)}</td>
	  <td>{"  ",$date_output}</td>
	  <td nowrap="nowrap">{app:get-edition-and-number($doc)} </td>
	  <td class="tools">
	    <a target="_blank"
            title="View XML source" 
            href="/storage/dcm/{util:document-name($doc)}">
	      <img src="/editor/images/xml.gif" 
	      alt="view source" 
	      border="0"
              title="View source" />
	    </a>
	  </td>
	  <td class="tools">{app:edit-form-reference($doc)}</td>
	  <td class="tools">{app:copy-document-reference($doc)}</td>
	  <td class="tools">{app:get-publication-reference($doc)}</td>
	  <td class="tools">{app:delete-document-reference($doc)}</td>
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
	    <div style="float:right;">
	      <a title="Add new file" href="#" class="addLink" 
	      onclick="location.href='/filter/new/dcm/'; return false;"><img 
	      src="/editor/images/new.gif" alt="New file" border="0" /></a>
	      &#160;
	      <a href="/editor/manual/" 
	      class="addLink"
	      target="_blank"><img 
	      src="/editor/images/help_light.png" 
	      title="Help - opens the manual in a new window or tab" 
	      alt="Help" 
	      border="0"/></a>
	    </div>
	    <img src="/editor/images/mermeid_30px.png" 
            title="MerMEId - Metadata Editor and Repository for MEI Data" 
	    alt="MerMEId Logo"/>
	  </div>
	  <div class="filter_bar">
	    <table class="filter_block">
	      <tr>
		<td class="label">Filter by: &#160;</td>
		<td class="label">Publication status</td>
		<td class="label">Collection</td>
		<td class="label">Keywords</td>
	      </tr>
	      <tr>
		<td>&#160;</td>
		<td>
		  <form method="get" id="status-selection" action="/storage/list_files.xq" >
		    <select name="published_only" onchange="this.form.submit();">
		      {
  			for $alt in app:options()
			  let $option :=
			    if( $alt/@value eq $published_only ) then
		               <option value="{$alt/@value/text()}" 
			       selected="selected">
				 {$alt/text()}
			       </option>
			    else
			      $alt 
			  return $option
		      }
		      </select> 
		      {app:pass-as-hidden-except("published_only")}
		    </form>
		</td>
		<td>
		
		  <select onchange="location.href=this.value; return false;">
		    {
            	      for $c in distinct-values(
            		collection("/db/dcm")//m:seriesStmt/m:identifier[@type="file_collection" and string-length(.) > 0]/string())
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
            <form action="/storage/list_files.xq" method="get" class="search">
              <input name="query"  value='{request:get-parameter("query","")}'/>
              <input name="c"      value='{request:get-parameter("c","")}'    type='hidden' />
              <input name="published_only" value='{request:get-parameter("published_only","")}' type='hidden' />
              <input name="itemsPerPage"  value='{$number}' type='hidden' />
              <input type="submit" value="Search"               />
              <input type="submit" value="Clear" onclick="this.form.query.value='';this.form.submit();return true;"/>
              <a class="help">?<span class="comment">Search terms may be combined using boolean operators. Wildcards allowed. 
                  Search is case insensitive (except for boolean operators, which must be uppercase).
                  Some examples:<br/>
                  <span class="help_table">
                    <span class="help_example">
                      <span class="help_label">carl OR nielsen</span>
                      <span class="help_value">Boolean OR (default)</span>
                    </span>                        
                    <span class="help_example">
                      <span class="help_label">carl AND nielsen</span>
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
      let $list := loop:getlist($database,$published_only,$coll,$genre,$query)
      return
      <div class="files_list">
        <div class="nav_bar">
          {app:navigation($sort-options,$list)}
        </div>
           
        <table border='0' cellpadding='0' cellspacing='0' class='result_table'>
          <tr>
            <th>Composer</th>
            <th>Title</th>
            <th>Year</th>
            <th>Collection</th>
            <th class="tools" >XML</th>
            <th class="tools">Edit</th>
            <th class="tools">Copy</th>
            <th class="tools">	   
              <form method="get" id="publish_form" action="/storage/publish.xq" >
                <div id="publish">
                Publish 
                <img src="/editor/images/menu.png" 
                alt="Publishing menu" 
                onmouseover="document.getElementById('publish_menu').style.visibility='visible'"
                onmouseout="document.getElementById('publish_menu').style.visibility='hidden'"
                style="vertical-align: text-top;"/>
                <div class="popup" 
                     id="publish_menu" 
                     onmouseover="document.getElementById('publish_menu').style.visibility='visible'"
                     onmouseout="document.getElementById('publish_menu').style.visibility='hidden'">
               
                  <button 
                     type="submit" 
                     onclick="document.getElementById('publishingaction').value='publish';">
                    <img src="/editor/images/publish.png" alt="Publish"/>
                    Publish selected files
		  </button>
                  <br/>
                  <button 
                     type="submit"
                     onclick="document.getElementById('publishingaction').value='retract';">
                    <img src="/editor/images/unpublish.png" alt="Unpublish"/>
                    Unpublish selected files
		  </button>
                                   
               	  <input name="publishing_action" 
               	         type="hidden"
                         value="publish" 
                         id="publishingaction" />
                  {app:pass-as-hidden()}
                               
                  <hr/>
                               
                  <button type="button"
                          onclick="check_all();">
                    <img src="/editor/images/check_all.png" alt="Check all" title="Check all"/>
                    Select all files
		  </button>
                  <br/>
                  <button type="button"
                          onclick="un_check_all();">
                    <img src="/editor/images/uncheck_all.png" 
		         alt="Uncheck all" 
			 title="Uncheck all"/>
                         Unselect all files
		  </button>
                </div>
                </div>
              </form>
           	   
            </th>
            <th class="tools">Delete</th>
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
           src="/editor/images/dcm_logo_small_white.png"/></a>
           Danish Centre for Music Editing | The Royal Library, Copenhagen | <a name="www.kb.dk" id="www.kb.dk" href="http://www.kb.dk/dcm">www.kb.dk/dcm</a>
    </div>
  </body>
</html>
