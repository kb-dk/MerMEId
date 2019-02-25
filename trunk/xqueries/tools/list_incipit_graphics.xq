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
declare variable $resolution := request:get-parameter("res","lowres");


declare function local:movement-title ($key as node()) as xs:string
{
    let $num := 
    if($key/@n!='')
    then
        concat($key/@n, '. ')
    else
        ''
        
    let $title :=
    if ($key/m:titleStmt/m:title[string-length(.)>0] and $key/m:tempo[string-length(.)>0])
    then
        concat($key/m:titleStmt/m:title[string-length(.)>0][1],'. ')
    else 
        $key/m:titleStmt/m:title[string-length(.)>0][1]

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
        <div>
            {local:movement-title($expression)}<br/>
            {
                for $img at $pos in $expression/m:incip/m:graphic[@targettype=$resolution and @target!='']
                return
                    <div style="margin-bottom:1em;">
                    {
                        element img { 
                            attribute src {$expression/m:incip/m:graphic[@targettype=$resolution][$pos]/@target} 
                        }
                    }
                    <br/>
                    {string($expression/m:incip/m:graphic[@targettype=$resolution][$pos]/@target)}
                    </div>
             }
             {
                for $expr in $expression/(m:expressionList|m:componentList)/m:expression[descendant-or-self::m:incip/m:graphic[@targettype=$resolution and @target!='']]
            	    (: loop through sub-expressions (acts/movements) :)
                     return local:movement($expr)
             }
        </div>
    return $output
};

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
    </head>
	<body>
	
		<h2>Incipit graphics</h2>
		
		    {
		          if($collection="") then
                    <tr><td>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
                    (for instance, ?c=CNW) to the URL.<br/>
                    To select a different resolution, add a &apos;res&apos; parameter to your query. Values supported by MerMEId include &amp;res=lowres, &amp;res=hires, and &amp;res=print. 
                    Default is lowres.
                    </td></tr>
                  else 
		    
            	    for $c in collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection and m:workList/m:work//m:expression/m:incip/m:graphic[@targettype=$resolution and @target!='']]
                    order by local:sort-key(string($c/m:workList/m:work/m:identifier[@label=$collection])) 
            	    return 
            	       <div class="work" style="margin-left:2em;">
            	         <p class="heading" style="page-break-after: avoid; margin-left:-2em;"><b>{concat($collection,' ',$c/m:workList/m:work/m:identifier[@label=$collection]/string(),' ',$c/m:workList/m:work[1]/m:titleStmt/m:title[@type='main' or not(@type)][1]/string())}</b></p>
            	         {
            	         for $expr in $c/m:workList/m:work/m:expressionList/m:expression[descendant-or-self::m:incip/m:graphic[@targettype=$resolution and @target!='']]
            	         (: loop through main expressions (versions) :)
                         return local:movement($expr)
            	         }
            	       </div>
            }

    </body>
</html>
