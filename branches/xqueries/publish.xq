import module namespace login="http://kb.dk/this/login" at "./login.xqm";

declare namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace util="http://exist-db.org/xquery/util";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $dcmroot := "xmldb:exist:///db/dcm/";
declare variable $pubroot := "xmldb:exist:///db/public/";
declare variable $action  := 
request:get-parameter("publishing_action","publish") cast as xs:string;

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
    let $doc         := doc($parameter)
    let $destination :=concat("public/",substring-after($parameter,"dcm/"))
    where request:get-parameter($parameter,"") eq 'publish'
      and not(contains($parameter,"action"))
    return 
    <tr>
      <td>parameter = {$parameter}</td>
      <td>destination = {$parameter}</td>
      <td>name = {util:document-name($doc)}</td>
      <td>
	{
	  if($action eq 'publish') then
	    xdb:store($pubroot,util:document-name($doc), $doc)
	  else
	    if(doc-available($destination)) then
	      xdb:remove($pubroot,util:document-name($doc))
	    else
	      ()
    	}
      </td>
    </tr>
  }
</table>


