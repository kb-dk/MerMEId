xquery version "1.0" encoding "UTF-8";

(: If the server chokes on this one, try the two-step approach: generate a list of names first and find the occurrences next :)

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
declare variable $invert := request:get-parameter("invert","false");


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
  if(contains($key,' ') and $invert='true') then
    concat(tokenize($key,"\s+")[last()],', ',substring($key,1,string-length($key)-string-length(tokenize($key,"\s+")[last()])))
  else 
    $key 
  return $txt 
};

declare function loop:sort-key ($num as xs:string) as xs:string
{
  let $sort_key:=
      (: make the work number a 15 character long string padded with zeros :)
      let $padded_number:=concat("0000000000000000",normalize-space($num))
      let $len:=string-length($padded_number)-14
	return substring($padded_number,$len,15)
  return $sort_key
};


<html xmlns="http://www.w3.org/1999/xhtml">
	<body>

    <h2>Provenance</h2>
    <div>
 
		    {
		          if($collection="") then
                    <p>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
                    (for instance, ?c=CNW) to the URL</p>
                  else 
                    for $c in distinct-values(
            		collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection]/
            		m:fileDesc/m:sourceDesc/m:source//m:provenance/m:eventList/m:event/m:p
                    /string()[string-length(.) > 0])  
                    (: IF the provenance text field (paragraph) contains only a name, name inversion may be used.  :)
                    (: In that case, you may want to change the preceding line to 
                    /normalize-space(loop:clean-names(string()))[string-length(.) > 0]) 
                    :)
                    order by loop:invert-names($c) 
            	    return
            		  <div>{concat(loop:invert-names($c),' &#160; ',$collection,' ')} 
            		  {let $numbers :=
            		  for $n in collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection]
                         where $n/m:fileDesc/m:sourceDesc/m:source//m:provenance/m:eventList/m:event/m:p = $c
                         order by loop:sort-key(string($n/m:workDesc/m:work/m:identifier[@label=$collection])) 
                	     return $n/m:workDesc/m:work/m:identifier[@label=$collection]/string()
                	   return string-join($numbers,', ') 
                   	   } 
                	   </div>

            }
    </div>


  </body>
</html>
