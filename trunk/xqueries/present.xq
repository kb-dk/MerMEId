xquery version "1.0" encoding "UTF-8";

import module namespace rd="http://kb.dk/this/redirect" at "./redirect_host.xqm";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace app="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace ft="http://exist-db.org/xquery/lucene";

declare option exist:serialize "method=xml media-type=text/html"; 
declare variable $document := request:get-parameter("doc", "");
declare variable $language := request:get-parameter("language", "");
declare variable $score := request:get-parameter("score", "");
declare variable $xsl := request:get-parameter("xsl", "mei_to_html.xsl");
declare variable $display_authority_links := request:get-parameter("display_authority_links", "");

let $host := rd:host()
let $docname := 
    if(contains($document,"/"))
    then tokenize($document,"/")[last()]
    else $document
let $exist-coll := concat("/db/dcm/", substring-before($document,$docname))
let $list := 
   for $doc in xmldb:xcollection($exist-coll)
   where util:document-name($doc)=$docname
   return $doc

let $params := 
<parameters>
   <param name="hostname" value="{$host}"/>
   <param name="doc" value="{$document}"/>
   <param name="language" value="{$language}"/>
   <param name="score" value="{$score}"/>
   <param name="display_authority_links" value="{$display_authority_links}"/>
</parameters>

for $doc in $list
return 
if(request:get-parameter("debug","")) then
(<d>{$params}{doc(concat("/db/mermeid/style/",$xsl))}</d>)
else
transform:transform($doc,doc(concat("/db/mermeid/style/",$xsl)),$params)
 
