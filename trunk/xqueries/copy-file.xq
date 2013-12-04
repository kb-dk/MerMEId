import module namespace login="http://kb.dk/this/login" at "./login.xqm";

declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace uuid="java:java.util.UUID";

declare option    exist:serialize "method=xml media-type=text/html"; 

declare variable $dcmroot := "/db/dcm/";

let $return_to := concat(
  "http://",request:get-header('HOST'),"/storage/list_files.xq?",
  "sortby=",             fn:escape-uri(request:get-parameter("sortby",""),true()),
  "&amp;published_only=",fn:escape-uri(request:get-parameter("published_only",""),true()),
  "&amp;c=",             fn:escape-uri(request:get-parameter("c",""),true()),
  "&amp;query=",         fn:escape-uri(request:get-parameter("query",""),true()),
  "&amp;page=",          fn:escape-uri(request:get-parameter("page",""),true()),
  "&amp;itemsPerPage=",  fn:escape-uri(request:get-parameter("itemsPerPage",""),true()))


let $log-in := login:function()
let $res := response:redirect-to($return_to cast as xs:anyURI)
let $parameters :=  request:get-parameter-names()

return
<table>
  {
    for $parameter in $parameters 
    let $new_file := concat($dcmroot,uuid:to-string(uuid:random-UUID()),".xml")
    let $old_file := concat($dcmroot,$parameter)
    where request:get-parameter($parameter,"")="copy" and contains($parameter,"xml")
    return
    let $odoc    := doc($old_file)
    let $stored  := xdb:store($dcmroot,$new_file, $odoc )
    let $new_doc := doc($new_file)
    for $title in $new_doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1][string()]
    let $new_title := concat($title//string()," (copy) ")
    let $upd := update replace $title[string()][1] with <m:title>{$new_title}</m:title>
    return <tr><td>{$title[string()][1]//string()}</td><td>{$new_title}</td></tr>
  }
</table>


