xquery version "1.0" encoding "UTF-8";

(: Search the a mei document store and return the data as an atom feed :)

import module namespace loop="http://kb.dk/this/getlist" at "./main_loop.xqm";

declare default element namespace "http://www.kb.dk/dcm";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace app="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace dc="http://purl.org/dc/elements/1.1/";

declare option exist:serialize "method=xml media-type=application/atom+xml"; 

declare variable $coll     := request:get-parameter("subject",  "");
declare variable $document := request:get-parameter("document", "");
declare variable $query    := request:get-parameter("query",    "");
declare variable $page     := request:get-parameter("page",    "1") cast as xs:integer;

declare variable $number   :=
                 request:get-parameter("itemsPerPage","20")   cast as xs:integer;

declare variable $from     := ($page - 1) * $number + 1;
declare variable $to       :=  $from      + $number - 1;

declare variable $host_port_context :=  "disdev-01.kb.dk";

declare function app:format-doc(
	$doc  as node(),
	$pos  as xs:integer,
	$from as xs:integer,
	$to   as xs:integer ) as node() {

   let $ref   := 
    <file>
        <series>{m:meiHead/m:fileDesc/m:seriesStmt/m:title}</series>
        <seriesId>[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier}</seriesId>
        <composer>{m:meiHead/m:workDesc/m:work/m:respStmt/m:persName[@role='composer']}</composer>
        <title>{m:meiHead/m:workDesc/m:work/m:titleStmt/m:title[text()][1]}</title>
	<link 
	href="{request:get-effective-uri()}?document={util:document-name($doc)}" />

        <sources>
            <source xml:id="{m:meiHead/m:fileDesc/m:sourceDesc/m:source/@xml:id}">
                <title>{m:meiHead/m:fileDesc/m:sourceDesc/m:source/m:titleStmt/m:title[text()][1]}</title>
            </source>
        </sources>
    </file>
  </file>
  return $ref
};

<fileList>
  {
    let $list := 
	loop:getlist($coll,$query)

     let $intotal := fn:count($list/m:meiHead)
       return (
         for $doc at $count in $list[position() = ($from to $to)]
		app:format-doc($doc,$count,$from,$number)
       )
  }

</fileList>
