xquery version "1.0" encoding "UTF-8";

(: Creates a simple list of performance venues without indication of city or references to which works were performed :)

declare namespace loop="http://kb.dk/this/getlist";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace fn="http://www.w3.org/2005/xpath-functions";

declare namespace m="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $database := "/db/dcm";
declare variable $collection := request:get-parameter("c","");


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


<html xmlns="http://www.w3.org/1999/xhtml">
	<body>

     <h2>Performance venues list</h2>
    <div>
 
		    {
		          if($collection="") then
                    <p>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
                    (for instance, ?c=CNW) to the URL</p>
                  else 
                    for $c in distinct-values(
            		collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection]/
            		m:workDesc/m:work//m:eventList[@type='performances']/m:event/m:geogName[@role='venue' and normalize-space(.)] )
                    order by normalize-space(string($c))
            	    return
            		  <div>
                		  {normalize-space($c)} 
                	  </div>

            }
    </div>



  </body>
</html>

