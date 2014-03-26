xquery version "1.0" encoding "UTF-8";

declare namespace xdb     = "http://exist-db.org/xquery/xmldb";
declare namespace file    = "http://exist-db.org/xquery/file";
declare namespace util    = "http://exist-db.org/xquery/util";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace m       = "http://www.music-encoding.org/ns/mei";
declare namespace h       = "http://expath.org/ns/http-client";

(: declare namespace impl    = "urn:X-EXPath:httpclient:samples:exist:impl"; :)

(: declare namespace http    = "java:org.apache.commons.httpclient.HttpClient";
declare namespace get     = "java:org.apache.commons.httpclient.methods.GetMethod";
declare namespace put     = "java:org.apache.commons.httpclient.methods.PutMethod";
declare namespace head    = "java:org.apache.commons.httpclient.methods.HeadMethod"; :)

declare variable $linebreak := "
" cast as xs:string;

declare variable $database := request:get-parameter("db","/db/dcm") cast as xs:string;
declare variable $coll     := request:get-parameter("c","cnw")      cast as xs:string;

declare option exist:serialize "method=text media-type=text/plain"; 



declare function get-stuff() as node()
{
  let $rest := 'http://localhost:8080/exist/rest'
  let $in   := "fdsaf"
  let $user := "fdsaf"
  let $pass := "fdsaf"
  let $req  := <h:request href="{ $rest }{ $in }"
    method="get"
    username="{ $user }"
    password="{ $pass }"
    auth-method="basic"
    send-authorization="true"/>

    return <blah/>
  (:    h:send-request($req)[2]:)
};


(:$doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll:)

let $since := request:get-parameter("since","2014-01-01T00:00:00+01:00") cast as xs:dateTime
return
  if(true()) then
    for $doc in collection($database)/
      m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll]
      where (xdb:last-modified( $database,util:document-name($doc)) < $since)
      return concat(util:document-name($doc),
      " ",
      xdb:last-modified( $database,util:document-name($doc)),
      " ",
      $linebreak)
  else
    for $doc in collection($database)/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll]
    return concat(util:document-name($doc),
      " ",
      xdb:last-modified( $database,util:document-name($doc)),
      " ",
      $linebreak)
