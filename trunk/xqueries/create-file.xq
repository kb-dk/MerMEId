xquery version "3.0";

import module namespace login="http://kb.dk/this/login" at "./login.xqm";
import module namespace rd="http://kb.dk/this/redirect" at "./redirect_host.xqm";

declare namespace xs="http://www.w3.org/2001/XMLSchema";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/html";

let $log-in     := login:function()
let $exist_path := request:get-parameter("path","")
let $new_doc    := doc("./new_file.xml")
let $host       := rd:host()

let $uri  := concat("uri=","http://",$host,"/editor/forms/mei/edit-work-case.xml")
let $dir  := concat("dir=","http://",$host,"/filter/")
let $file := concat(util:uuid(),".xml")
let $file_arg := concat("doc=",$file)
let $args := string-join(($uri,$dir,$file_arg),"&amp;")

let $return_to := concat("http://",$host,"/orbeon/xforms-jsp/mei-form/?",$args)
let $res       := response:redirect-to($return_to cast as xs:anyURI)
let $result    := xmldb:store("/db/dcm",$file , $new_doc)

return
<table>
<tr><td>uri</td><td>{$uri}</td></tr>
<tr><td>dir</td><td>{$dir}</td></tr>
<tr><td>file</td><td>{$file}</td></tr>
<tr><td>args</td><td>{$args}</td></tr>
<tr><td>redirect</td><td>{$return_to}</td></tr>
</table>
