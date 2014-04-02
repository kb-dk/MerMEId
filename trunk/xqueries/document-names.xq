xquery version "1.0" encoding "UTF-8";

declare namespace xdb        = "http://exist-db.org/xquery/xmldb";
declare namespace file       = "http://exist-db.org/xquery/file";
declare namespace util       = "http://exist-db.org/xquery/util";
declare namespace request    = "http://exist-db.org/xquery/request";
declare namespace m          = "http://www.music-encoding.org/ns/mei";
declare namespace httpclient = "http://exist-db.org/xquery/httpclient";
declare namespace logger     = "java:org.apache.log4j.Logger";
declare namespace local      = "http://kb.dk/this/app";

declare variable $linebreak := "
" cast as xs:string;

declare variable $database := request:get-parameter("db","/db/dcm") cast as xs:string;
declare variable $coll     := request:get-parameter("c","cnw")      cast as xs:string;

declare variable $suri     := "http://dcm-udv-01.kb.dk:8080/exist/rest";
declare variable $duri     := "http://dcm-udv-01.kb.dk:8080/exist/rest";

declare variable $logger   := logger:getLogger("document-names -- ");

declare option exist:serialize "method=xml media-type=application/xhtml+xml"; 


    (: username="{ $user }"
    password="{ $pass }"
    auth-method="basic"
    send-authorization="true"/> 
    :)

declare function local:timestamp-to-xs-date($dt as xs:string) as xs:dateTime {
(: convert timestamps in the form 0505 Tue 08 Jul to xs:dateTime :)
   let $year := year-from-date(current-date())  (: assume the current year since none provided :)
   let $dtp := tokenize($dt," ")
   let $mon := index-of(("Jan","Feb", "Mar","Apr","May", "Jun","Jul","Aug","Sep","Oct","Nov","Dec"),$dtp[4])
   let $monno := if($mon < 10) then concat("0",$mon) else $mon
   return xs:dateTime(concat($year,"-",$monno,"-",$dtp[3],"T",substring($dtp[1],1,2),":",substring($dtp[1],3,4),":00"))
};

declare function local:head($url) as node(){
  let $username    := "admin"
  let $password    := "flormelis"
  let $credentials := concat($username, ':', $password)
  let $encode      := util:string-to-binary($credentials)
  let $value       := concat('Basic ', $encode)
  let $new-headers := <headers><header name="Authorization" value="{$value}"/></headers>
  let $response    := httpclient:head( xs:anyURI($url), true(), $new-headers)
  return $response
};

declare function local:put($url, $doc) as node(){
  let $username    := "admin"
  let $password    := "flormelis"
  let $credentials := concat($username, ':', $password)
  let $encode      := util:string-to-binary($credentials)
  let $value       := concat('Basic ', $encode)
  let $new-headers :=
  <headers>
     <header name="Authorization" value="{$value}"/>
  </headers>
  let $response := httpclient:put( xs:anyURI($url), $doc, true(), $new-headers)
  return $response
};


(:$doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll:)

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>bläääh</title>
<meta http-equiv="Content-Type" content="application/xhtml+xml;charset=UTF-8"/>
</head>
<body>
<table>
{
  let $since := request:get-parameter("since","2014-01-01T00:00:00+01:00") cast as xs:dateTime
  return
  for $doc in collection($database)
  let $destination := concat($duri,'/',$coll,'/data/',util:document-name($doc)) 
  where (xdb:last-modified( $database,util:document-name($doc)) < $since) and
    $doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll
    return
      <tr>
	<td>{util:document-name($doc)}</td>
	<td>{$destination}</td>
	<td>{xdb:last-modified( $database,util:document-name($doc))}</td>
	<td>
	{
	  let $putstatus := local:put($destination,$doc)
	  let $headstatus := local:head($destination)
	  return $putstatus 
(:          return $headstatus/httpclient:response/@statusCode/string() :)
	}
	</td>
      </tr>
  }
</table>
</body>
</html>
