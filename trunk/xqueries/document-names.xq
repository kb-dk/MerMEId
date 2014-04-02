xquery version "1.0" encoding "UTF-8";

declare namespace xdb     = "http://exist-db.org/xquery/xmldb";
declare namespace file    = "http://exist-db.org/xquery/file";
declare namespace util    = "http://exist-db.org/xquery/util";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace m       = "http://www.music-encoding.org/ns/mei";
declare namespace h       = "http://exist-db.org/xquery/httpclient";

declare namespace logger  = "java:org.apache.log4j.Logger";

declare namespace local="http://kb.dk/this/app";

declare variable $linebreak := "
" cast as xs:string;

declare variable $database := request:get-parameter("db","/db/dcm") cast as xs:string;
declare variable $coll     := request:get-parameter("c","cnw")      cast as xs:string;

declare variable $suri     := "http://dcm-udv-01.kb.dk:8080/exist/rest";
declare variable $duri     := "http://dcm-udv-01.kb.dk:8080/exist/rest";

declare variable $logger   := logger:getLogger("document-names -- ");

declare option exist:serialize "method=text media-type=text/plain"; 


    (: username="{ $user }"
    password="{ $pass }"
    auth-method="basic"
    send-authorization="true"/> 
    :)




declare function local:put-stuff($doc as node()) as xs:string?
{
    let $destination := concat($duri,'/',$coll,'/data/',util:document-name($doc)) 
    let $source      := concat($suri,$database,'/',util:document-name($doc))
    let $user        := "admin"
    let $passwd      := "flormelis"
    let $req         := <h:request href="{ $destination }"
      method="put"
      username="{ $user   }"
      password="{ $passwd }"
      auth-method="basic"
      send-authorization="true">
      <h:body media-type="application/xml"/>
    </h:request>

    let $res := <h:response status="500 fake response"/> 
    let $source-doc := <m:mei>{$doc}</m:mei>  

    return $res/h:response/@status/string()[1] 

};


declare function local:get-stuff($doc as node()) as xs:string
{
  let $source := concat($suri,$database,'/',util:document-name($doc))
  let $user := "admin"
  let $pass := "flormelis"
  let $req  := <h:request href="{ $source }" method="head" />
  let $entry := logger:debug($logger,$source)
  let $response := <h:response status="500 fake response"/> 
  return concat($source, " ", $response/h:response/@status/string())

};


declare function local:put($url, $content) as node(){
  let $username    := "admin"
  let $password    := "flormelis"
  let $credentials := concat($username, ':', $password)
  let $encode      := util:string-to-binary($credentials)
  let $value       := concat('Basic ', $encode)
  let $new-headers :=
  <headers>
     <header name="Authorization" value="{$value}"/>
  </headers>
  let $response := httpclient:put( xs:anyURI($url), $content, false(), $new-headers)
  return $response
};


(:$doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll:)

let $since := request:get-parameter("since","2014-01-01T00:00:00+01:00") cast as xs:dateTime
return
  if(true()) then
    for $doc in collection($database)
      let $destination := concat($duri,'/',$coll,'/data/',util:document-name($doc)) 
      where (xdb:last-modified( $database,util:document-name($doc)) < $since) and
	$doc/m:mei/m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll
      return
	concat(util:document-name($doc),
	" ",
	$destination,
	" ",
	xdb:last-modified( $database,util:document-name($doc)),
	" ",
	local:put($destination,$doc),
	$linebreak)
  else
    for $doc in collection($database)
    let $destination := concat($duri,'/',$coll,'/data/',util:document-name($doc)) 
    where $doc/m:mei/m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll
    return concat(util:document-name($doc),
      " ",
      xdb:last-modified( $database,util:document-name($doc)),
      " ",
      $destination,
      " ",
      local:put($destination,$doc),
      $linebreak
	   )
