xquery version "1.0" encoding "UTF-8";

(: Search the a mei document store and return the data as an atom feed :)

import module namespace loop="http://kb.dk/this/getlist" at "./main_loop.xqm";

declare default element namespace "http://www.w3.org/2005/Atom";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace app="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace opensearch="http://a9.com/-/spec/opensearch/1.1/";


declare option exist:serialize "method=xml media-type=application/atom+xml"; 

declare variable $coll     := request:get-parameter("subject",  "");
declare variable $document := request:get-parameter("document", "");
declare variable $query    := request:get-parameter("query",    "");
declare variable $page     := request:get-parameter("page",    "1") cast as xs:integer;

declare variable $number   :=
                 request:get-parameter("itemsPerPage","20")   cast as xs:integer;

declare variable $from     := ($page - 1) * $number + 1;
declare variable $to       :=  $from      + $number - 1;

declare variable $host_port_context :=  "distest.kb.dk";

declare function app:format-document(
  $doc  as node(),
  $pos  as xs:integer,
  $from as xs:integer,
  $to   as xs:integer ) as node() {

  let $ref   := 
  <entry>
    <author>
      <name>{$doc/m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='composer']/string()}</name>
    </author>
    <title>
    {$doc//m:title[@type="main"][1]/string()}
    </title>
    <link 
    href="{request:get-effective-uri()}?document={util:document-name($doc)}" />
    <content type="xhtml">
    {transform:transform($doc, 
    xs:anyURI("http://distest.kb.dk/editor/transforms/mei/mei_to_html_div.xsl"), ())}
    </content>
  </entry>
  return $ref
};


declare function app:format-reference(
  $doc  as node(),
  $pos  as xs:integer,
  $from as xs:integer,
  $to   as xs:integer ) as node() {

  let $terms := $doc//m:profiledesc//m:term[string()]  
  let $num   := fn:count($terms)

  let $keywords :=
     for $term at $count in $terms
     return 
       if($count = $num) then
	 $term/string()
       else
	 fn:concat($term/string(),", ")

  let $ref   := 
  <entry>
    <author>
      <name>{$doc/m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='composer']/string()}</name>
    </author>
    <title>
    {$doc//m:title[@type="main"][1]/string()}
    </title>
    <link 
    href="http://{$host_port_context}/data/biblio/2012/jan/dcm/da/?document={util:document-name($doc)}" />
    <content type="xhtml">
    <div xmlns="http://www.w3.org/1999/xhtml">
    <p>
      <h2>{$doc/m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='composer']/string()}
      {" "}
      <a href="http://{$host_port_context}/data/biblio/2012/jan/dcm/da/?document={util:document-name($doc)}">
      {$doc//m:title[@type="main"][1]/string()}</a></h2>
      {$keywords}
    </p>
    <br/>
    </div>
    </content>
  </entry>
  return $ref
};

declare function app:list-title() {
  let $title :=
    if(not($coll)) then
      "All works"
    else
      ($coll," works")

  return $title
};

declare function app:link-section($total as xs:integer,
                                  $start as xs:integer,
				  $items as xs:integer,
				  $coll  as xs:string) as node()* 
{
  let $uri   := request:get-effective-uri() cast as xs:string

  let $collection :=
    if(not($coll)) then
      ""
    else
      if($coll="all") then
	""
      else
	("c=",$coll)

  let $perpage  := fn:concat("itemsPerPage=",$items)
  let $nextpage := ($page+1) cast as xs:string
  let $next     :=
    if($start+$items<$total) then
      element link {
	attribute rel {"next"},
	attribute href {
	  fn:string-join(
	    ($uri,
	    "?",
	    "page=",
	    $nextpage,
	    $perpage,
	    $collection),
	    ""
	    )
	}
      }
    else
      "" 

  let $prevpage := ($page - 1) cast as xs:string
  let $previous :=
    if($start - $items + 1 > 0) then
      element link {
	attribute rel {"prev"},
	attribute href {
	  fn:string-join(
	    ($uri,
	    "?",
	    "page=",
	    $prevpage,
	    $perpage,
	    $collection),
	    ""
	    )
	}
      }
    else
      "" 

  let $links :=
    (element link {
      attribute rel {"self"},
      attribute href {fn:string-join(($uri,"?",$collection),"")}
    },element link {
      attribute rel {"first"},
      attribute href {$uri}
    },
    $previous,
    $next,
    element link {
      attribute rel {"last"},
      attribute href {$uri}
    })

  return $links
};


declare function app:opensearch-header($total as xs:integer,
                                       $start as xs:integer,
				       $items as xs:integer,
		                       $coll  as xs:string) as node()* {
  let $header := 
  (<opensearch:totalResults>{$total}</opensearch:totalResults>,
  <opensearch:startIndex>{$start}</opensearch:startIndex>,
  <opensearch:itemsPerPage>{$items}</opensearch:itemsPerPage>,
  <link rel="search" 
        type="application/opensearchdescription+xml" 
	href="http://example.com/opensearchdescription.xml"/>,
  <opensearch:Query role="request" searchTerms="New York History" startPage="1" />)

  return $header

};

<feed>
  <author>
    <name>Dansk Center for Musikudgivelse</name>
  </author>
  <title>
    {app:list-title()}
  </title>
  <id>{request:get-effective-uri()}</id>

  {
    let $list := 
      if($document) then 
	for $doc in collection("/db/dcm")/m:mei
	where util:document-name($doc)=$document
	return $doc
      else
	loop:getlist($coll,$query)

     let $intotal := fn:count($list/m:meihead)
  
       return ( (: app:link-section($intotal,
         $from,
	 $number,
	 $coll), :)
         app:opensearch-header($intotal,
	 $from,
	 $number,
	 $coll),
         for $doc at $count in $list[position() = ($from to $to)]
	   return 
	     if($document) then
               app:format-document($doc,$count,$from,$number)
	     else
               app:format-reference($doc,$count,$from,$number)
       )
  }

</feed>
