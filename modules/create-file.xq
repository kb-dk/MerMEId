xquery version "3.0";

import module namespace login="http://kb.dk/this/login" at "./login.xqm";
import module namespace config="https://github.com/edirom/mermeid/config" at "./config.xqm";

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/html";

let $log-in     := login:function()
let $exist_path := request:get-parameter("path","")
let $new_doc    := doc("../forms/model/new_file.xml")

let $file := concat(util:uuid(),".xml")
let $file_arg := concat("doc=",$file)

let $return_to := concat(config:link-to-app("/forms/edit-work-case.xml"), "?", $file_arg)
let $res       := response:redirect-to($return_to cast as xs:anyURI)
let $result    := xmldb:store($config:data-root, $file, $new_doc)

return
<table>
<tr><td>file</td><td>{$file}</td></tr>
<tr><td>redirect</td><td>{$return_to}</td></tr>
</table>
