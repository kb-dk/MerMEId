xquery version "1.0" encoding "UTF-8";

(: Generates a list of incipits graphic files ordered by work (catalogue) number :)

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


declare function local:source-title ($key as node()) as xs:string
{
        
    let $title :=
    if ($key/m:titleStmt/m:title[string-length(.)>0] and $key/@label[string-length(.)>0])
    then
        concat($key/@label,': ',$key/m:titleStmt/m:title[string-length(.)>0][1])
    else 
        concat($key/@label,$key/m:titleStmt/m:title[string-length(.)>0][1])

    let $titleAlways :=
        concat($key/@label,': ',$key/m:titleStmt/m:title[string-length(.)>0][1])

    return $title 
};

declare function local:sort-key ($num as xs:string) as xs:string
{
  let $sort_key:=
      (: make the number a 15 character long string padded with zeros :)
      let $padded_number:=concat("0000000000000000",normalize-space($num))
      let $len:=string-length($padded_number)-14
	return substring($padded_number,$len,15)
  return $sort_key
};

declare function local:source($source) as node()
{
    let $output :=
        <div  style="margin-bottom:1em;">
            {local:source-title($source)}
            {
                let $count:= count($source/m:physDesc/m:provenance/m:eventList/m:event/m:p[string-length(normalize-space(.)) > 0])
                for $listItem at $pos in $source/m:physDesc/m:provenance/m:eventList/m:event/m:p[string-length(normalize-space(.)) > 0]
                let $label :=
                    if($pos = 1) 
                    then
                        'Provenance: '
                    else
                        ''
                
                let $separator :=
                    if($pos < $count) 
                    then
                        '; '
                    else
                        ''
                return
                    concat($label,string($listItem),$separator)
             }
             {
                for $src in $source/(m:itemList|m:componentList)[descendant-or-self::m:provenance/m:eventList/m:event/m:p[string-length(normalize-space(.)) > 0]]/(m:item|m:source)
            	    (: loop through sub-sources/items. :)
            	    (: to limit to sources having provenance info: add [descendant-or-self::m:provenance/m:eventList/m:event/m:p[string-length(normalize-space(.)) > 0]] :)
                     return <div style="margin-left: 1em;">{local:source($src)}</div>
             }
             &#160;
        </div>
    return $output
};

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
    </head>
	<body>
	
		<h2>Source provenance</h2>
		
		    {
		          if($collection="") then
                    <tr><td>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
                    (for instance, ?c=CNW) to the URL</td></tr>
                  else 
		    
            	    for $c in collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection and 
            	    m:fileDesc/m:sourceDesc/m:source//m:provenance/m:eventList/m:event/m:p[string-length(normalize-space(.)) > 0]]
                    order by local:sort-key(string($c/m:workList/m:work/m:identifier[@label=$collection])) 
            	    return 
            	       <div class="work" style="margin-left:2em;">
            	         <p class="heading" style="page-break-after: avoid; margin-left:-2em;"><b>{concat($collection,' ',$c/m:workList/m:work/m:identifier[@label=$collection]/string(),' ',$c/m:workList/m:work[1]/m:title[@type='main' or not(@type)][1]/string())}</b></p>
            	         {
            	         for $source in $c/m:fileDesc/m:sourceDesc/m:source
            	         (: loop through sources :)
                 	     (: to limit to sources having provenance info: add [descendant-or-self::m:provenance/m:eventList/m:event/m:p[string-length(normalize-space(.)) > 0]] :)
                         return local:source($source)
            	         }
            	       </div>
            }

    </body>
</html>
