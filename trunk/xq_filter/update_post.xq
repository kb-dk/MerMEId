xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/html";

let $method:= request:get-method()
let $data := request:get-parameter("file","")
let $log-in := xmldb:login("/db", "admin", "flormelis")

let $exist_path  := request:get-parameter("path","")

let $result := if($exist_path) then
    xmldb:store("/db/garbage",$exist_path , $data)
else
    ()

return
<html>
<head><title>script for checking things</title></head>
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
</table>
</body>
</html>