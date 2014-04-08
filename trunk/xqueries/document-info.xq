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
declare variable $coll     := lower-case(request:get-parameter("c","cnw") cast as xs:string);

declare variable $base-uri := request:get-parameter("base-uri","http://dcm-udv-01.kb.dk:8080/exist/rest");

declare variable $logger   := logger:getLogger("document-names -- ");

declare option exist:serialize "method=text media-type=text/plain"; 

let $since  := request:get-parameter("since", "2014-01-01T00:00:00+01:00") cast as xs:dateTime
let $before := request:get-parameter("before","2099-01-01T00:00:00+01:00") cast as xs:dateTime

return
for $doc in collection($database)
let $source := concat($base-uri,$database,util:document-name($doc)) 
let $modified    := xdb:last-modified( $database,util:document-name($doc))
let $thiscoll   := lower-case($doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string())
where ( $modified > $since and $modified < $before and $thiscoll = $coll )
return
  (util:document-name($doc),
  " ",
  xdb:last-modified($database,util:document-name($doc)),
  $linebreak)
