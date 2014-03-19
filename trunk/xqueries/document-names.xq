xquery version "1.0" encoding "UTF-8";

declare namespace file    = "http://exist-db.org/xquery/file";
declare namespace util    = "http://exist-db.org/xquery/util";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace m       = "http://www.music-encoding.org/ns/mei";

declare variable $linebreak := "
" cast as xs:string;

declare variable $database := request:get-parameter("db","/db/dcm") cast as xs:string;
declare variable $coll     := request:get-parameter("c","cnw")      cast as xs:string;

declare option exist:serialize "method=text media-type=text/plain"; 

(:$doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll:)

for $doc in collection($database)/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll]
  return concat(util:document-name($doc),$linebreak)
