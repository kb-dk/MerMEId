xquery version "1.0" encoding "UTF-8";

import module namespace config="https://github.com/edirom/mermeid/config" at "./config.xqm";

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

let $host := request:get-hostname()
let $list := 
for $doc in collection($config:data-root)
where util:document-name($doc)=$document
return $doc

let $params := 
<parameters>
   <param name="hostname" value="{$host}"/>#
   <param name="app-root" value="{$config:app-root}"/>
   <param name="data-root" value="{$config:data-root}"/>
   <param name="doc" value="{$document}"/>
   <param name="language" value="{$language}"/>
   <param name="score" value="{$score}"/>
   <param name="display_authority_links" value="{$display_authority_links}"/>
</parameters>

for $doc in $list
return 
if(request:get-parameter("debug","")) then
(<d>{$params}{doc(concat($config:app-root,"/style/",$xsl))}</d>)
else
transform:transform($doc,doc(concat($config:app-root,"/style/",$xsl)),$params)
 
