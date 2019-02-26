import module namespace login="http://kb.dk/this/login" at "./login.xqm";
import module namespace rd="http://kb.dk/this/redirect" at "./redirect_host.xqm";

declare namespace functx = "http://www.functx.com";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace util="http://exist-db.org/xquery/util";


declare option    exist:serialize "method=xml media-type=text/html"; 

declare variable $dcmroot := "/db/dcm/";

declare variable $host    := rd:host();

declare function functx:copy-attributes
  ( $copyTo as element() ,
    $copyFrom as element() )  as element() {

   element { node-name($copyTo)}
           { $copyTo/@*[not(node-name(.) = $copyFrom/@*/node-name(.))],
             $copyFrom/@*,
             $copyTo/node() }

 } ;



let $return_to := concat("http://",$host,"/storage/list_files.xq?")


let $log-in := login:function()
let $res := response:redirect-to($return_to cast as xs:anyURI) 
let $parameters :=  request:get-parameter-names()

return
<table>
  {
    for $parameter in $parameters 
    let $new_file := concat($dcmroot,util:uuid(),".xml")
    let $old_file := concat($dcmroot,$parameter)
    where request:get-parameter($parameter,"")="copy" and contains($parameter,"xml")
    return
    let $odoc    := doc($old_file)
    let $stored  := xmldb:store($dcmroot,$new_file, $odoc )
    let $new_doc := doc($new_file)
    for $title in $new_doc//m:workList/m:work[1]/m:title[string()][1]
    let $new_title_text := concat($title//string()," (copy) ")
    let $new_title := 
    <title xmlns="http://www.music-encoding.org/ns/mei">{$new_title_text}</title>
    let $upd := update replace $title[string()] with
      functx:copy-attributes($new_title,$title)
    return <tr><td>{$title[string()][1]//string()}</td><td>{$new_title_text}</td></tr>
  }
</table>


