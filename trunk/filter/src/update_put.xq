xquery version "3.1";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace login="http://kb.dk/this/login" at "./login.xqm";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/html";


let $data        := request:get-data()
let $method      := request:get-method()

(: let $log-in      := login:function() not needed if setuid admin :)

let $exist_path  := request:get-parameter("path","")

let $transform   := if(true()) then
    xs:anyURI("/db/apps/filter/xsl/filter_put.xsl")
else
    xs:anyURI("/db/apps/filter/xsl/null_transform.xsl")

let $op          := doc($transform)
let $params      := <parameters/>
let $file        := request:get-parameter("resource","")  (: replace($exist_path, "/*","") :)

(:
let $tdoc        := transform:transform($data,$op,$params)

let $result      := if($file and $tdoc) then
    xmldb:store("/db/dcm",$file , $tdoc)
else
    ()
:)
return
<html>
<head><title>script for saving things to database</title></head>
<body>
<h1>script for checking things</h1>
<p>uri {request:get-uri()}</p>
<table>
<tr><td>parameter</td><td>value</td></tr>
{
   for $par in request:get-parameter-names() 
	return <tr><td>{xs:string($par)}</td><td>{request:get-parameter($par,"")}</td></tr>
}
<tr><td>my method</td><td>{$method}</td></tr>
<tr><td>saving file to</td><td>{$file}</td></tr>
<tr><td>saving file</td><td>{$exist_path}</td></tr>
<tr><td>content is document</td><td>{$data instance of document-node() }</td></tr>
<tr><td>data</td><td>{$data}</td></tr>
</table>
</body>
</html>