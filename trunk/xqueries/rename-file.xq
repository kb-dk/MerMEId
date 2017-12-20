import module namespace login="http://kb.dk/this/login" at "./login.xqm";


declare namespace functx = "http://www.functx.com";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace uuid="java:java.util.UUID";

declare option    exist:serialize "method=xml media-type=text/html"; 

declare variable $dcmroot := "/db/dcm/";
declare variable $doc     := request:get-parameter("doc", "");
declare variable $name := request:get-parameter("name", "");

declare function functx:copy-attributes
  ( $copyTo as element() ,
    $copyFrom as element() )  as element() {

   element { node-name($copyTo)}
           { $copyTo/@*[not(node-name(.) = $copyFrom/@*/node-name(.))],
             $copyFrom/@*,
             $copyTo/node() }

 } ;




let $log-in := login:function()
let $new_name := 
    if (substring($name,string-length($name)-3,4)=".xml") then
        $name
    else
        concat($name,".xml")

let $return_to := concat("http://",request:get-header('HOST'),"/storage/list_files.xq")
let $res := response:redirect-to($return_to cast as xs:anyURI) 
let $result:=
  if ($doc!="" and $name!="") then
    xdb:rename($dcmroot, $doc, $new_name)
  else 
    ""

return
    $result
    