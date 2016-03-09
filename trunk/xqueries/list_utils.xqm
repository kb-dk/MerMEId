xquery version "1.0" encoding "UTF-8";

module namespace  app="http://kb.dk/this/listapp";

import module namespace  filter="http://kb.dk/this/app/filter" at "./filter_utils.xqm";

declare namespace file="http://exist-db.org/xquery/file";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace xl="http://www.w3.org/1999/xlink";
declare namespace xdb="http://exist-db.org/xquery/xmldb";

declare variable $app:notbefore := request:get-parameter("notbefore",   "") cast as xs:string;
declare variable $app:notafter  := request:get-parameter("notafter",    "") cast as xs:string;
declare variable $app:coll      := request:get-parameter("c",           "") cast as xs:string;
declare variable $app:query     := request:get-parameter("query",       "");
declare variable $app:page      := request:get-parameter("page",        "1") cast as xs:integer;
declare variable $app:number    := request:get-parameter("itemsPerPage","20") cast as xs:integer;
declare variable $app:genre     := request:get-parameter("genre",       "")   cast as xs:string;
declare variable $app:sortby    := request:get-parameter("sortby",      "person,title") cast as xs:string;
declare variable $app:from      := ($app:page - 1) * $app:number + 1;
declare variable $app:to        :=  $app:from      + $app:number - 1;

declare variable $app:published_only := 
request:get-parameter("published_only","") cast as xs:string;

declare function app:options() as node()*
{ 
let $options:= 
  (
  <option value="">All documents</option>,
  <option value="any">Published</option>,
  <option value="pending">Modified</option>,
  <option value="unpublished">Unpublished</option>)

  return $options
};


declare function app:pass-as-hidden() as node()* {
  let $inputs :=
    (
    <input name="published_only" type="hidden" value="{$app:published_only}"   />,
    <input name="c"              type="hidden" value="{$app:coll}"   />,
    <input name="query"          type="hidden" value="{$app:query}"  />,
    <input name="page"           type="hidden" value="{$app:page}"   />,
    <input name="itemsPerPage"   type="hidden" value="{$app:number}" />,
    <input name="genre"          type="hidden" value="{$app:genre}" />,
    <input name="notbefore"      type="hidden" value="{$app:notbefore}" />,
    <input name="notafter"       type="hidden" value="{$app:notafter}" />,
    <input name="sortby"         type="hidden" value="{$app:sortby}" />
    )
    return $inputs
};

declare function app:generate-href($field as xs:string,
  $value as xs:string) as xs:string {
    let $inputs := app:pass-as-hidden()
    let $pars   :=
    for $inp in $inputs

    let $str:=
      if($field = $inp/@name/string() ) then
	string-join(($field,fn:escape-uri($value,true())),"=")
      else
	string-join(($inp/@name,fn:escape-uri($inp/@value,true())),"=")
	return 
	  $str

	  let $link := string-join($pars,"&amp;")
	  return $link

  };


  declare function app:pass-as-hidden-except(
    $field as xs:string)  as node()* 
    {

      let $inputs:=
      for $input in app:pass-as-hidden()
      return
	if($input/@name ne $field) then
	  $input
	else
	  if($input/@name eq "page") then
	    (<input name="page" type="hidden" value="1" />)
	  else
	    ()
	    
	    return $inputs
    };

    declare function app:get-publication-reference($doc as node() )  as node()* 
    {
      let $doc-name:=util:document-name($doc)
      let $color_style := 
	if(doc-available(concat("public/",$doc-name))) then
	  (
	    let $dcmtime := xs:dateTime(xdb:last-modified("dcm",   $doc-name))
	    let $pubtime := xs:dateTime(xdb:last-modified("public",$doc-name))
	    return
	      if($dcmtime lt $pubtime) then
		"publishedIsGreen"
	      else
		"pendingIsYellow"
           )
         else
	   "unpublishedIsRed"

      let $form:=
      <form id="formsourcediv{$doc-name}"
      action="/storage/list_files.xq" 
      method="post" style="display:inline;">
      
	<div id="sourcediv{$doc-name}"
             style="display:inline;">
		
	  <input id="source{$doc-name}" 
	         type="hidden" 
		 value="publish" 
		 name="dcm/{$doc-name}" 
		 title="file name"/>

	  <label class="{$color_style}" for='checkbox{$doc-name}'>
	    <input id='checkbox{$doc-name}'
	    onclick="add_publish('sourcediv{$doc-name}',
	    'source{$doc-name}',
	    'checkbox{$doc-name}');" 
	    type="checkbox" 
	    name="button" 
	    value="" 
	    title="publish"/>
	  </label>

	</div>
      </form>
      return $form
    };

    declare function app:get-edition-and-number($doc as node() ) as xs:string* {
      let $c := 
	  $doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"][1]/string()
      let $no := $doc//m:meiHead/m:workDesc/m:work[1]/m:identifier[@label=$c][1]/string()
      (: shorten very long identifiers (i.e. lists of numbers) :)
	  let $part1 := substring($no, 1, 11)
	  let $part2 := substring($no, 12)
      let $delimiter := substring(concat(translate($part2,'0123456789',''),' '),1,1)
      let $n := 
          if (string-length($no)>11) then 
            concat($part1,substring-before($part2,$delimiter),'...')
          else
            $no
      return ($c, $n)	
    };

    declare function app:view-document-reference($doc as node()) as node() {
      (: it is assumed that we live in /storage :)
      let $ref := 
      <a  target="_blank"
      title="View" 
      href="/storage/present.xq?doc={util:document-name($doc)}">
	{$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1]/string()}
      </a>
      return $ref
    };

    declare function app:public-view-document-reference($doc as node()) as node()* {
      (: it is assumed that we live in /storage :)
      let $langs :=
	comment{
	    for $lang in distinct-values($doc//m:workDesc/m:work[1]/m:titleStmt[1]/m:title[string()]/@xml:lang/string())
	    return $lang
	  }
      let $ref := 
	($langs,
	element span {
	  attribute lang {$doc//m:workDesc/m:work[1]/m:titleStmt[1]/m:title[string()][not(@type/string())][1]/@xml:lang},
	  element a {
	    attribute title {"View"},
	    attribute href  {concat("/storage/document.xq?doc=",util:document-name($doc))},
	  $doc//m:workDesc/m:work[1]/m:titleStmt[1]/m:title[string()][not(@type/string())][1]/string()
	  },
	  element span {
	    attribute style {"font-size: 75%;"},
	    concat($doc//m:workDesc/m:work[1]/m:titleStmt[1]/m:title[string()][@type/string()='subordinate'][1]/string(),"&#160;")
	  }
	},
	element span {
	  attribute style {"display:none;"},
	  attribute lang {"en"},
	  element a {
	    attribute title {"View"},
	    attribute href  {concat("/storage/document.xq?doc=",util:document-name($doc))},
	    concat($doc//m:workDesc/m:work[1]/m:titleStmt[1]/m:title[string()][@xml:lang='en' and not(@type/string())]/string(),"&#160;")
	  },
	  element span {
	    attribute style {"font-size: 75%;"},
	    concat($doc//m:workDesc/m:work[1]/m:titleStmt[1]/m:title[string()][@xml:lang='en' and @type/string()='subordinate']/string(),"&#160;")
	  }
	}
	)
      return $ref
    };
    
    declare function app:edit-form-reference($doc as node()) as node() 
    {
      (: 
      Beware: Partly hard coded reference here!!!
      It still assumes that the document resides on the same host as this
      xq script but on port 80

      The old form is called edit_mei_form.xml the refactored one starts on
      edit-work-case.xml 
      :)

      let $form-id := util:document-name($doc)
      let $ref := 
      <form id="edit{$form-id}" 
      action="/orbeon/xforms-jsp/mei-form/" style="display:inline;" method="get">

	<input type="hidden"
        name="uri"
	value="http://{request:get-header('HOST')}/editor/forms/mei/edit-work-case.xml" />
	<input type="hidden"
 	name="doc"
	value="{util:document-name($doc)}" />
	<input type="image"
 	title="Edit" 
	src="/editor/images/edit.gif" 
	alt="Edit" />
	{app:pass-as-hidden()}
      </form>

      return $ref

    };


    declare function app:copy-document-reference($doc as node()) as node() 
    {
      let $form-id := util:document-name($doc)
      let $uri     := concat("/db/public/",util:document-name($doc))
      let $form := 
      <form id="copy{$form-id}" action="./copy-file.xq" method="get" style="display:inline;">
	{app:pass-as-hidden()}
	<input type="hidden" 
	value="copy"
	name="{util:document-name($doc)}" />
	<input type="image" 
	src="/editor/images/copy.gif"  
	name="button"
	value="copy"
	title="Copy"/>
      </form>
      return  $form
    };



    declare function app:delete-document-reference($doc as node()) as node() 
    {
      let $form-id := util:document-name($doc)
      let $uri     := concat("/db/public/",util:document-name($doc))
      let $form := 
	if(doc-available($uri)) then
	<span>
	  <img src="/editor/images/remove_disabled.gif" alt="Remove (disabled)" title="Only unpublished files may be deleted"/>
	</span>
      else
      <form id="del{$form-id}" 
      action="http://{request:get-header('HOST')}/filter/delete/dcm/{util:document-name($doc)}"
      method="post" 
      style="display:inline;">
	{app:pass-as-hidden()}
	<input type="hidden" 
	name="file"
	value="{request:get-header('HOST')}/storage/dcm/{util:document-name($doc)}"
	title="file name"/>
	<input 
	onclick="{string-join(('show_confirm(&quot;del',$form-id,'&quot;,&quot;',$doc//m:workDesc/m:work/m:titleStmt/m:title[string()][1]/string(),'&quot;);return false;'),'')}" 
	type="image" 
	src="/editor/images/remove.gif"  
	name="button"
	value="delete"
	title="Delete"/>
      </form>
      return  $form
    };

    declare function app:list-title() 
    {
      let $title :=
	if(not($app:coll)) then
	  "All documents"
	else
	  ($app:coll, " documents")

	  return $title
    };


    declare function app:navigation( 
      $sort-options as node()*,
      $list as node()* ) as node()*
      {

	let $total := fn:count($list/m:meiHead)
	let $uri   := "" 
	let $nextpage := ($app:page+1) cast as xs:string

	let $next     :=
	  if($app:from + $app:number <$total) then
	    (element a {
	      attribute rel   {"next"},
	      attribute title {"Go to next page"},
	      attribute class {"paging"},
	      attribute href {
		fn:string-join((
		  $uri,"?",
		  app:generate-href("page",$nextpage)),"")
	      },
	      element img {
		attribute src {"/editor/images/next.png"},
		attribute alt {"Next"},
		attribute border {"0"}
	      }
	    })
	  else
	    ("") 

	    let $prevpage := ($app:page - 1) cast as xs:string

	    let $previous :=
	      if($app:from - $app:number + 1 > 0) then
		(
		  element a {
		    attribute rel {"prev"},
		    attribute title {"Go to previous page"},
		    attribute class {"paging"},
		    attribute href {
       		      fn:string-join(
			($uri,"?",
			app:generate-href("page",$prevpage)),"")},
			element img {
			  attribute src {"/editor/images/previous.png"},
			  attribute alt {"Previous"},
			  attribute border {"0"}
			}
		  })
		else
		  ("") 

		  let $app:page_nav := for $p in 1 to fn:ceiling( $total div $app:number ) cast as xs:integer
		  return 
		    (if(not($app:page = $p)) then
		    element a {
		      attribute title {"Go to page ",xs:string($p)},
		      attribute class {"paging"},
		      attribute href {
       			fn:string-join(
			  ($uri,"?",
			  app:generate-href("page",xs:string($p))),"")
		      },
		      ($p)
		    }
		  else 
		    element span {
		      attribute class {"paging selected"},
		      ($p)
		    }
		  )

		  let $work := 
		    if($total=1) then
		      " work"
		    else
		      " works"

		  let $links := ( 
		    element div {
		      element strong {
			"Found ",$total, $work 
		      },
		      if($sort-options) then
			(<form action="" id="sortForm" style="display:inline;float:right;">
			<select name="sortby" onchange="this.form.submit();return true;"> 
			{
			  for $opt in $sort-options
			    let $option:=
			      if($opt/@value/string()=$app:sortby) then
			        element option {
				  attribute value {$opt/@value/string()},
				  attribute selected {"selected"},
				  concat("Sort by: ",$opt/string())}
			      else
			        element option {
				  attribute value {$opt/@value/string()},$opt/string()}
   			    return $option
			}
			</select>
			{app:pass-as-hidden-except("sortby")}
			</form>)
		      else
			(),
		      (<form action="" id="itemsPerPageForm" style="display:inline;float:right;">
		      <select name="itemsPerPage" onchange="this.form.submit();return true;"> 
			{(
			  element option {attribute value {"10"},
			  if($app:number=10) then 
			    attribute selected {"selected"}
			  else
			    "",
			    "10 results per page"},
			    element option {attribute value {"20"},
			    if($app:number=20) then 
			      attribute selected {"selected"}
			    else
			      "",
			      "20 results per page"},
			      element option {attribute value {"50"},
			      if($app:number=50) then 
				attribute selected {"selected"}
			      else
				"",
				"50 results per page"},
				element option {attribute value {"100"},
				if($app:number=100) then 
				  attribute selected {"selected"}
				else
				  "",
				  "100 results per page"},
				  element option {attribute value {$total cast as xs:string},
				  if($app:number=$total or $app:number>$total) then 
				    attribute selected {"selected"}
				  else
				    "",
				    "View all results"}
			 )}
		      </select>

		      {app:pass-as-hidden-except("itemsPerPage")}
		      
		      </form>),
		      if ($total > $app:number) then
		         element div {
       		        attribute class {"paging_div"},
       			    $previous,"&#160;",
       			    $app:page_nav,
       			    "&#160;", $next}
       		  else "",
			  element br {
			     attribute clear {"both"}
			  }
		    })
		    return $links
      };
