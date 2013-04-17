import module namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";

declare variable $dcmroot    := 'dcm/';
declare variable $pubroot    := 'public/';

let $res := response:redirect-to("./list_files.xq" cast as xs:anyURI)
let $log-in := xdb:login("/db", "admin", "flormelis")
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
	<doc>
	Destination: {xdb:store($pubroot,$put_to, $doc)}
	</doc>
}
</docs>


