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
declare namespace marc="http://www.loc.gov/MARC21/slim";

declare namespace local="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $database := "/db/dcm";
declare variable $rism_dir := "/db/rism_sigla";
declare variable $country_codes := doc(concat($rism_dir,'/RISM_country_codes.xml'));
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

declare function loop:sort-key ($num as xs:string) as xs:string
{
  let $sort_key:=
      (: make the work number a 15 character long string padded with zeros :)
      let $padded_number:=concat("0000000000000000",normalize-space($num))
      let $len:=string-length($padded_number)-14
	return substring($padded_number,$len,15)
  return $sort_key
};


declare function loop:lookup ($location as xs:string) as xs:string
{
  let $country_code:=substring-before($location,'-')
  let $filename:=concat($country_code,'.xml')
  let $txt:=
    if($country_codes/m:list/m:li/m:geogName[@dbkey=$country_code])
    then
      concat(loop:lookup-archive($location, $country_code),', ',$country_codes/m:list/m:li/m:geogName[@dbkey=$country_code])
    else 
      concat($location,', ',$country_codes/m:list/m:li/m:geogName[@dbkey=$country_code])
	return $txt
};

declare function loop:lookup-archive ($location as xs:string, $country_code as xs:string) as xs:string
{
  let $archives:=doc(concat($rism_dir,'/',$country_code,'.xml'))
  let $archive:=
    if($archives/marc:collection/marc:record/marc:datafield[@tag='110']/marc:subfield[@code='g' and .=normalize-space($location)])
    then
      $archives/marc:collection/marc:record[marc:datafield[@tag='110']/marc:subfield[@code='g' and .=normalize-space($location)]]
    else 
      ""
  let $txt:=
    if($archive!='')
    then 
        concat($archive/marc:datafield[@tag='110']/marc:subfield[@code='a'],', ',$archive/marc:datafield[@tag='110']/marc:subfield[@code='c'])
    else
        $location
  return $txt
};



<html xmlns="http://www.w3.org/1999/xhtml">
	<body>

    <h2>Locations</h2>
    <div>
 
		    {
		          if($collection="") then
                    <p>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
                    (for instance, ?c=CNW) to the URL</p>
                  else 
                    for $c in distinct-values(
            		collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection]/
            		m:fileDesc/m:sourceDesc/m:source//m:physLoc/m:repository/
            		(m:identifier[@authority='RISM' and normalize-space(.)] | m:corpName[normalize-space(.)]) )
                    order by normalize-space(string($c))
            	    return
            		  <div>
            		  {concat(loop:lookup($c),' &#160; ',$collection,' ')} 
            		  {let $numbers :=
            		  for $n in collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection]
                         where $n/m:fileDesc/m:sourceDesc/m:source//m:physLoc/m:repository/
            		      (m:identifier[@authority='RISM' and normalize-space(.)] | m:corpName[normalize-space(.)]) = $c
                         order by loop:sort-key($n/m:workDesc/m:work/m:identifier[@label=$collection]/string()) 
                	     return $n/m:workDesc/m:work/m:identifier[@label=$collection]/string()
                	   return string-join($numbers,', ') 
                   	   } 
                	   </div>

            }
    </div>


  </body>
</html>
