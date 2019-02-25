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
(: desired resolution; MerMEId supports values "lowres", "hires", and "print" :) 
declare variable $resolution := "lowres";


declare function local:movement-title ($key as node()) as xs:string
{
    let $num := 
    if($key/@n!='')
    then
        concat($key/@n, '. ')
    else
        ''
        
    let $title := $key/m:titleStmt/m:title[string-length(.)>0][1]

    return concat($num,$title,$key/m:tempo[string-length(.)>0][1]) 
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

declare function local:movement($expression) as node()
{
    let $output :=
        <span>
            {local:movement-title($expression)}<br/>
            {
                if(not($expression/m:incip/m:graphic[@targettype=$resolution and @target!='']))
                then 
                    let $tempo :=
                    if(normalize-space($expression/m:tempo[1])) then
                        <span><b>Tempo: </b> {string($expression/m:tempo[1])}<br/></span>
                        else ''
                    let $meter1 :=
                    if(normalize-space($expression/m:meter[1]/@symbol)) then
                        <span><b>Metre: </b> {$expression/m:meter[1]/@symbol}<br/></span>
                        else ''
                    let $meter2 :=
                    if(normalize-space(concat($expression/m:meter[1]/@count,$expression/m:meter[1]/@unit))) then
                        <span><b>Metre: </b> {concat($expression/m:meter[1]/@count,'/',$expression/m:meter[1]/@unit)}<br/></span>
                        else ''
                    let $key :=
                    if(normalize-space($expression/m:key[1])) then
                        <span><b>Key: </b> {string($expression/m:key[1])}<br/></span>
                        else ''
                    let $incip :=
                    if(normalize-space($expression/m:incip/m:incipText[1]/m:p[1])) then
                        <span><b>Text incipit: </b> {string($expression/m:incip/m:incipText[1]/m:p[1])}<br/></span>
                        else ''
                    let $p :=
                        <span>{$tempo, $meter1, $meter2, $key, $incip}<br/></span>
                    return $p
                  else 
                    ''
             }
             {
                for $expr in $expression/(m:expressionList|m:componentList)/m:expression[descendant-or-self::*[normalize-space(concat(m:incip/m:incipText[1]/m:p[1]/string(),m:tempo[1]/string(),m:key[1]/string(),m:meter[1]/string()))!='']
                    	    [not(descendant-or-self::*/m:incip/m:graphic[@targettype=$resolution and @target!=''])]]
            	    (: loop through sub-expressions (acts/movements) :)
                     return local:movement($expr)
             }
        </span>
    return $output
};

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
    </head>
	<body>
	
		<h2>Tempo, key, metre, and text incipits in movements without music incipit</h2>
		    {
		          if($collection="") then
                    <tr><td>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
                    (for instance, ?c=CNW) to the URL</td></tr>
                  else 
		    
            	    for $c in collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection and m:workList/m:work//m:expression[
            	    normalize-space(concat(m:incip/m:incipText[1]/m:p[1]/string(),m:tempo[1]/string(),m:key[1]/string()))!='' and
            	    not(descendant-or-self::*/m:incip/m:graphic[@targettype=$resolution and @target!=''])]]
                    order by local:sort-key(string($c/m:workList/m:work/m:identifier[@label=$collection])) 
            	    return 
            	       <div class="work" style="margin-left:2em;">
            	         <h3 class="heading" style="page-break-after: avoid; margin-left:-2em;"><b>{concat($collection,' ',$c/m:workList/m:work/m:identifier[@label=$collection]/string(),' ',$c/m:workList/m:work[1]/m:titleStmt/m:title[@type='main' or not(@type)][1]/string())}</b></h3>
            	         {
            	         for $expr in $c/m:workList/m:work/m:expressionList/m:expression[descendant-or-self::*[normalize-space(concat(m:incip/m:incipText[1]/m:p[1]/string(),m:tempo[1]/string(),m:key[1]/string()))!='']
                    	    [not(descendant-or-self::*/m:incip/m:graphic[@targettype=$resolution and @target!=''])]]
            	         (: loop through main expressions (versions) :)
                         return local:movement($expr)
            	         }
            	       </div>
            }

    </body>
</html>
