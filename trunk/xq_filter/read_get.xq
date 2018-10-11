xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace xs="http://www.w3.org/2001/XMLSchema";

declare option exist:serialize "method=xml encoding=UTF-8 media-type=application/xml";

let $transform   := if(true()) then
    xs:anyURI("/db/apps/filter/xsl/filter_get.xsl")
else
    xs:anyURI("/db/apps/filter/xsl/null_transform.xsl")

let $exist_path  := request:get-parameter("path","")

let $op          := doc($transform)
let $doc         := doc(string-join(("/db/garbage",$exist_path), "/"))
let $params      := <parameters/>

let $tdoc        := transform:transform($doc,$op,$params)

return $tdoc
