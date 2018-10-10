xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace util="http://exist-db.org/xquery/util";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

let $log-in := xmldb:login("/db", "admin", "flormelis")

let $method:= request:get-method()
let $data  := "" (:if(request:is-multipart-content()) then 
	util:base64-decode(util:base64-decode(request:get-uploaded-file-data("file")))
	else
	request:get-data()

let $result := xmldb:store("/db/garbage",$exist:path , $data) :)

let $result := "nothing done"

return if(matches($method,"post","i")) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
   <forward url="./update_post.xq">
      <add-parameter name="path" value="{$exist:path}"/>
      <add-parameter name="prefix" value="{$exist:prefix}"/>
      <add-parameter name="controller" value="{$exist:controller}"/>
      <add-parameter name="resource" value="{$exist:resource}"/>
      <add-parameter name="root" value="{$exist:root}"/>
      <add-parameter name="method" value="{$method}"/>
      <add-parameter name="data" value="{$data}"/>
      <add-parameter name="result" value="{$result}"/>
   </forward>
</dispatch>
else if(matches($method,"put","i")) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
   <forward url="./update_put.xq">
      <add-parameter name="path" value="{$exist:path}"/>
      <add-parameter name="prefix" value="{$exist:prefix}"/>
      <add-parameter name="controller" value="{$exist:controller}"/>
      <add-parameter name="resource" value="{$exist:resource}"/>
      <add-parameter name="root" value="{$exist:root}"/>
      <add-parameter name="method" value="{$method}"/>
      <add-parameter name="result" value="{$result}"/>
   </forward>
</dispatch>
else if(matches($method,"get","i")) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
   <forward url="./read_get.xq">
      <add-parameter name="path" value="{$exist:path}"/>
      <add-parameter name="prefix" value="{$exist:prefix}"/>
      <add-parameter name="controller" value="{$exist:controller}"/>
   </forward>
</dispatch>
else
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
   <redirect url="./error.html"/>
</dispatch>

    


