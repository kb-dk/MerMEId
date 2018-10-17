xquery version "3.0";

import module namespace login="http://kb.dk/this/login" at "./login.xqm";
declare namespace xs="http://www.w3.org/2001/XMLSchema";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/html";

let $log-in     := login:function()
let $exist_path := request:get-parameter("path","")
let $new_doc    := doc("/db/apps/filter/new_file.xml")
let $host       := request:get-header('HOST')

let $uri  := concat("uri=",$host,"/editor/forms/mei/edit-work-case.xml")
let $dir  := concat("dir=",$host,"/filter/")
let $file := concat("doc=",util:uuid(),".xml")
let $args := string-join(($uri,$dir,$new_doc),"&amp;")

let $return_to := concat("http://",$host,"/orbeon/xforms-jsp/mei-form/?",$args)
let $res       := response:redirect-to($return_to cast as xs:anyURI)
let $result    := xmldb:store("/db/dcm",$file , $new_doc)


