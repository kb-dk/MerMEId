import module namespace login="http://kb.dk/this/login" at "./login.xqm";

declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace uuid="java:java.util.UUID";

declare option    exist:serialize "method=xml media-type=text/html"; 

declare variable $dcmroot := 'dcm/';

let $return_to := concat(
  "http://",request:get-header('HOST'),"/storage/list_files.xq?",
  "published_only=",   fn:escape-uri(request:get-parameter("published_only",""),true()),
  "&amp;c=",           fn:escape-uri(request:get-parameter("c",""),true()),
  "&amp;query=",       fn:escape-uri(request:get-parameter("query",""),true()),
  "&amp;page=",        fn:escape-uri(request:get-parameter("page",""),true()),
  "&amp;itemsPerPage=",fn:escape-uri(request:get-parameter("itemsPerPage",""),true()))

let $res := response:redirect-to($return_to cast as xs:anyURI)
let $log-in := login:function()
let $parameters :=  request:get-parameter-names()

return
<table>
  {
    for $parameter in $parameters 
    let $put-to  := concat($dcmroot,uuid:to-string(uuid:random-UUID()),".xml")
    let $action  := request:get-parameter($parameter,"")
    let $doc     := doc($parameter)
    where contains($parameter,".xml") and ($action="copy")
    return
      <tr>
      <td>
	{xdb:store($dcmroot,$put-to, $doc)}
      </td>
      <td>
	{
      	  let $new_doc := doc($put-to)
	  return util:document-name($new_doc)
	}
	{
	  let $new_doc := doc($put-to)
	  for $title in $new_doc//m:workDesc/m:work[1]/m:titleStmt/m:title[string()][1]
	  let $new_title := concat($title//string()," (copy) ")
	  return
	    update value $title with $new_title
	}    
      </td>
      </tr>
}
</table>


