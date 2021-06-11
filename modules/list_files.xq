xquery version "3.0" encoding "UTF-8";

import module namespace loop="http://kb.dk/this/getlist" at "./main_loop.xqm";
import module namespace app="http://kb.dk/this/listapp"  at "./list_utils.xqm";
import module namespace config="https://github.com/edirom/mermeid/config" at "./config.xqm";

declare namespace xl="http://www.w3.org/1999/xlink";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";
declare namespace xi="http://www.w3.org/2001/XInclude";

declare namespace local="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/html"; 

(: get parameters, either from querystring or fall back to session attributes :)
declare variable $coll              := request:get-parameter("c", session:get-attribute("coll"));
declare variable $query             := request:get-parameter("query", session:get-attribute("query"));
declare variable $published_only    := request:get-parameter("published_only", session:get-attribute("published_only"));
declare variable $page              := xs:integer(request:get-parameter("page", session:get-attribute("page")));
declare variable $number            := xs:integer(request:get-parameter("itemsPerPage", session:get-attribute("number")));
declare variable $sortby            := request:get-parameter("sortby", session:get-attribute("sortby"));

declare variable $session := session:create();

(: save parameters as session attributes; set to default values if not defined :)
declare variable $session-coll      := session:set-attribute("coll", if ($coll!="") then $coll else "");
declare variable $session-query     := session:set-attribute("query", if ($query!="") then $query else "");
declare variable $session-published := session:set-attribute("published_only", if (not($published_only) or $published_only!="") then $published_only else "");
declare variable $session-page      := session:set-attribute("page", if ($page>0) then $page else "1");
declare variable $session-number    := session:set-attribute("number", if ($number>0) then $number else "20");
declare variable $session-sortby    := session:set-attribute("sortby", if ($sortby!="") then $sortby else "person,title");


declare variable $database := $config:data-root;

declare variable $from     := (xs:integer(session:get-attribute("page")) - 1) * xs:integer(session:get-attribute("number")) + 1;
declare variable $to       :=  $from      + xs:integer(session:get-attribute("number")) - 1;

declare variable $sort-options :=
(<option value="person,title">Composer,Title</option>,
<option value="person,date">Composer, Year</option>,
<option value="date,person">Year, Composer</option>,
<option value="date,title">Year, Title</option>,
<option value="null,work_number">Work number</option>
);


declare function local:format-reference(
  $doc as node(),
  $pos as xs:integer ) as node() {

    let $class :=
      if($pos mod 2 = 1) then 
	"odd"
      else
	"even"

      let $date_output :=
    	if($doc//m:workList/m:work/m:creation/m:date/(@notbefore|@notafter|@startdate|@enddate)!='') then
    	  concat(substring($doc//m:workList/m:work/m:creation/m:date/@notbefore,1,4),
    	  substring($doc//m:workList/m:work/m:creation/m:date/@startdate,1,4),
    	  '-',
    	  substring($doc//m:workList/m:work/m:creation/m:date/@enddate,1,4),
    	  substring($doc//m:workList/m:work/m:creation/m:date/@notafter,1,4))
        else if($doc//m:workList/m:work/m:creation/m:date/@isodate!='') then
          substring($doc//m:workList/m:work/m:creation/m:date[1]/@isodate,1,4)
        else if($doc//m:workList/m:work/m:expressionList/m:expression[m:creation/m:date][1]/m:creation/m:date/(@notbefore|@notafter|@startdate|@enddate)!='') then
    	  concat(substring($doc//m:workList/m:work/m:expressionList/m:expression[m:creation/m:date][1]/m:creation/m:date/@notbefore,1,4),
    	  substring($doc//m:workList/m:work/m:expressionList/m:expression[m:creation/m:date][1]/m:creation/m:date/@startdate,1,4),
    	  '-',
    	  substring($doc//m:workList/m:work/m:expressionList/m:expression[m:creation/m:date][1]/m:creation/m:date/@enddate,1,4),
    	  substring($doc//m:workList/m:work/m:expressionList/m:expression[m:creation/m:date][1]/m:creation/m:date/@notafter,1,4))
        else
          substring($doc//m:workList/m:work/m:expressionList/m:expression[m:creation/m:date][1]/m:creation/m:date[@isodate][1]/@isodate,1,4)

	(: for some reason the sort-key function must be called outside the actual searching to have correct work number sorting when searching within all collections :)
    let $dummy := loop:sort-key("dummy_collection", $doc, "null")

	let $ref   := 
	<tr class="result {$class}">
	  <td nowrap="nowrap">
	    {$doc//m:workList/m:work/m:contributor/m:persName[@role='composer']}
	  </td>
	  <td>{app:view-document-reference($doc)}</td>
	  <td>{"  ",$date_output}</td>
	  <td nowrap="nowrap">{app:get-edition-and-number($doc)}</td>
	  <td class="tools">
	    <a target="_blank"
            title="View XML source" 
            href="../data/{util:document-name($doc)}">
	      <img src="../resources/images/xml.gif" 
	      alt="view source" 
	      border="0"
              title="View source" />
	    </a>
	  </td>
	  <td class="tools">{app:edit-form-reference($doc)}</td>
	  <td class="tools">{app:copy-document-reference($doc)}</td>
	  <td class="tools">{app:rename-document-reference($doc)}</td>
	  <td class="tools">{app:get-publication-reference($doc)}</td>
	  <td class="tools">{app:delete-document-reference($doc)}</td>
	  <td nowrap="nowrap">{app:view-document-notes($doc)}</td>
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
	  href="../resources/css/list_style.css" 
	  type="text/css"/>
	  <link rel="styleSheet" 
	  href="../resources/css/xform_style.css" 
	  type="text/css"/>
	  
	  <script type="text/javascript" src="../resources/js/confirm.js">
	  //
	  </script>
	  
	  <script type="text/javascript" src="../resources/js/checkbox.js">
	  //
	  </script>
	  
	  <script type="text/javascript" src="../resources/js/publishing.js">
	  //
	  </script>

	</head>
	<body class="list_files">
	  <div class="list_header">
	    <div style="float:right;">
	      <form id="create-file" action="./create-file.xq" method="post" class="addLink"  style="display:inline;">
    	      <input type="image" src="../resources/images/new.gif" name="button" value="new" title="Add new file"/>
	      </form>&#160;<a href="../manual/index.html" 
	      class="addLink"
	      target="_blank"><img 
	      src="../resources/images/help_light.png" 
	      title="Help - opens the manual in a new window or tab" 
	      alt="Help" 
	      border="0"/></a>
	    </div>
	    <img src="../resources/images/mermeid_30px.png" 
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
		  <form action="" method="get" id="status-selection">
		    <input name="page" value="1" type="hidden"/>
		    <select name="published_only" onchange="this.form.submit();">
		      {
  			for $alt in app:options()
			  let $option :=
			    if( $alt/@value eq session:get-attribute("published_only") ) then
		               <option value="{$alt/@value/text()}" 
			       selected="selected">
				 {$alt/text()}
			       </option>
			    else
			      $alt 
			  return $option
		      }
		      </select> 
		    </form>
		</td>
		<td>
		  <form action="" method="get" id="collection-selection">
		      <input name="page" value="1" type="hidden"/>
    		  <select name="c" onchange="this.form.submit();">
    		    <option value="">All collections</option>
    		    {
               	      for $c in distinct-values(collection($database)//m:seriesStmt/m:identifier[@type="file_collection" and string-length(.) > 0]/string())
                        let $option :=
                		      if(not(session:get-attribute("coll")=$c)) then 
                		      <option value="{$c}">{$c}</option>
                	              else
                		      <option value="{$c}" selected="selected">{$c}</option>
                	   return $option
    		     }
    		  </select>
            </form>
          </td>
          <td>
            <form action="" method="get" class="search">
			  <input name="page" value="1" type="hidden"/>
              <input name="query"  value='{session:get-attribute("query")}'/>
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
      let $list := loop:getlist($database)
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
            <th class="tools">Rename</th>
            <th class="tools">	   
              <form method="get" id="publish_form" action="./publish.xq" >
                <div id="publish">
                Publish 
                <img src="../resources/images/menu.png" 
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
                    <img src="../resources/images/publish.png" alt="Publish"/>
                    Publish selected files
		  </button>
                  <br/>
                  <button 
                     type="submit"
                     onclick="document.getElementById('publishingaction').value='retract';">
                    <img src="../resources/images/unpublish.png" alt="Unpublish"/>
                    Unpublish selected files
		  </button>
                                   
               	  <input name="publishing_action" 
               	         type="hidden"
                         value="publish" 
                         id="publishingaction" />
                  <hr/>
                               
                  <button type="button"
                          onclick="check_all();">
                    <img src="../resources/images/check_all.png" alt="Check all" title="Check all"/>
                    Select all files
		  </button>
                  <br/>
                  <button type="button"
                          onclick="un_check_all();">
                    <img src="../resources/images/uncheck_all.png" 
		         alt="Uncheck all" 
			 title="Uncheck all"/>
                         Unselect all files
		  </button>
                </div>
                </div>
              </form>
           	   
            </th>
            <th class="tools">Delete</th>
            <th>Notes</th>
          </tr>
          {
            for $doc at $count in $list[position() = ($from to $to)]
            return local:format-reference($doc,$count)
          }
        </table>
      </div>
    }
    {config:replace-properties(config:get-property('footer'))}
  </body>
</html>

