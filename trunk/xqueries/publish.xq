import module namespace xdb="http://exist-db.org/xquery/xmldb";
module namespace login="http://kb.dk/this/login" at "./login.xqm";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";

declare variable $dcmroot := 'dcm/';
declare variable $pubroot := 'public/';
declare variable $action  := 
request:get-parameter("publishing_action","publish") cast as xs:string;

let $res := response:redirect-to("/storage/list_files.xq" cast as xs:anyURI)
let $log-in := login:function()
let $parameters :=  request:get-parameter-names()
return
<docs>
  {
    for $parameter in $parameters 
    let $doc         := doc($parameter)
    let $destination :=concat($pubroot,substring-after($parameter,$dcmroot))
    let $put_to :=substring-after($parameter,$dcmroot)
    where contains($parameter,$dcmroot)
    return 
    <doc action="{$action}">
      {
	if($action eq 'publish') then
	  xdb:store($pubroot,$put_to, $doc)
	else
	  if(doc-available($destination)) then
	    xdb:remove($pubroot,$put_to)
	  else
	    ()
      }
    </doc>
  }
</docs>


