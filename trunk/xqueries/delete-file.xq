xquery version "3.1" encoding "UTF-8";

import module namespace login="http://kb.dk/this/login" at "./login.xqm";

declare namespace functx = "http://www.functx.com";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";

declare option    exist:serialize "method=xml media-type=text/html"; 

declare variable $dcmroot := "/db/dcm/";

let $return_to := concat("http://",request:get-header('HOST'),"/storage/list_files.xq?")


let $log-in := login:function()
let $res := response:redirect-to($return_to cast as xs:anyURI) 
let $parameters :=  request:get-parameter-names()

return
<p>
  {
    for $resource in $parameters 
    where request:get-parameter($resource,"")="delete" and contains($resource,"xml")
    return xmldb:remove(xs:anyURI($dcmroot), $resource)
  }
</p>

(:
xquery version "3.1" encoding "UTF-8";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";

let $dcmroot := "/db/dcm/"
let $resource := "nielsen_cnw0126.xml"

return xmldb:remove(xs:anyURI($dcmroot), $resource)
:)



