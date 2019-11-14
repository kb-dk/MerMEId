xquery version "1.0" encoding "UTF-8";

(: Generates an index of venues and the works performed.          :)
(: The optional "city" parameter limits results to a single city. :) 
(: Example: performance_venues_index.xq?c=CNW&city=Berlin         :)

declare namespace loop="http://kb.dk/this/getlist";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace fn="http://www.w3.org/2005/xpath-functions";

declare namespace m="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $database := "/db/dcm";
declare variable $collection := request:get-parameter("c","");
declare variable $city := request:get-parameter("city","");


declare function loop:sort-key ($identifier as xs:string) as xs:string
{
  let $sort_key:=
      (: extract any trailing number :)
      let $number:= replace($identifier,'^.*?(\d*)$','$1')
      (: and anything that might be before the number :)
      let $prefix:= replace($identifier,'^(.*?)\d*$','$1')
      (: make the number a 15 character long string padded with zeros :)
      let $padded_number:=concat("0000000000000000",normalize-space($number))
      let $len:=string-length($padded_number)-14
	return concat($prefix,substring($padded_number,$len,15))
  return $sort_key
};


declare function loop:venue_and_place ($venue_place) {
    let $ret := if (substring-after($venue_place,'¤')='') then substring-before($venue_place,'¤') 
        else concat(substring-before($venue_place,'¤'),', ',substring-after($venue_place,'¤'))
    return $ret
};


<html xmlns="http://www.w3.org/1999/xhtml">
	<body>

     <h2>Performance venues index</h2>
    <div>
 
		    {
		          if($collection="") then
                    <p>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
                    (for instance, ?c=CNW) to the URL</p>
                  else 
                    for $c in distinct-values(
            		collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection]/
            		m:workDesc/m:work//m:eventList[@type='performances']/m:event[($city='' or m:geogName[@role='place' and .=$city]) and
            		m:geogName[@role='venue' and normalize-space(.)]]/concat(string(m:geogName[@role='venue' 
            		and normalize-space(.)][1]),'¤',string(m:geogName[@role='place'][1])))
                    order by $c
                    return
            		  <div>
            		  {loop:venue_and_place($c)}
            		  {
                      let $venue := substring-before($c,'¤')
                      let $place := substring-after($c,'¤')
            		  let $numbers :=
            		  for $n in collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection]
                         where $n/m:workDesc/m:work//m:eventList[@type='performances']/m:event[m:geogName[@role='venue' and normalize-space(.)] = $venue and
                         (m:geogName[@role='place'] = $place or (not(normalize-space($place)) and not(m:geogName[@role='place' and normalize-space(.)])))]
                         order by loop:sort-key($n/m:workDesc/m:work/m:identifier[@label=$collection]/string()) 
                	     return $n/m:workDesc/m:work/m:identifier[@label=$collection]/string()
                	   return concat('&#160;&#160;&#160;',$collection,' ',string-join($numbers,', ')) 
            		  
            		  }
                	  </div>

            }
    </div>



  </body>
</html>

