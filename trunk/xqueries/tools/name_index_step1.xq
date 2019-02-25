xquery version "1.0" encoding "UTF-8";

declare namespace loop="http://kb.dk/this/getlist";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";

declare namespace local="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $database := "/db/dcm";
declare variable $collection := request:get-parameter("c","");


declare function loop:clean-names ($key as xs:string) as xs:string
{
  (: strip off any text not part of the name (marked with a comma or parentheses) :)
  let $txt := concat(translate(normalize-space($key),',;(','***'),'*')
  return substring-before($txt,'*') 
};

declare function loop:invert-names ($key as xs:string) as xs:string
{
  (: put last name first; invert at last space in name string :)
  let $txt := 
  if(contains($key,' ')) then
    concat(tokenize($key,"\s+")[last()],', ',substring($key,1,string-length($key)-string-length(tokenize($key,"\s+")[last()])))
  else 
    $key 
  return $txt 
};

declare function loop:invert-namesAtFirstSpace ($key as xs:string) as xs:string
{
  (: put last name first; invert at first space in name string :)
  let $txt := 
  
  if(contains($key,' ')) then
    concat(normalize-space(substring-after($key,' ')),', ', normalize-space(substring-before($key,' ')))
  else 
    $key 
  return $txt 
};

    <div id="names" xmlns="http://www.music-encoding.org/ns/mei">
 
		    {
                  if($collection="") then
                    <p>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
                    (for instance, ?c=CNW) to the URL</p>
                  else 
                    for $c in distinct-values(
            		collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection]/
            		(m:fileDesc/m:sourceDesc//m:persName | m:workList/m:work//m:persName)
            		/normalize-space(loop:clean-names(string()))[string-length(.) > 0])
            		(: Add exception to last clause to exclude the composer, e.g. " and not(contains(.,'Carl Nielsen'))"  :)
                    order by loop:invert-names($c)
            	    return
            		  <persName>{$c}</persName>            		  
            }
    </div>
