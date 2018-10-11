xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare option exist:serialize "method=xml encoding=UTF-8 media-type=application/xml";

let $exist_path  := request:get-parameter("path","")

let $doc := doc(string-join(("/db/garbage",$exist_path), "/"))

return $doc
