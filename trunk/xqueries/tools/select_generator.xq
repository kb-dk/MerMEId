xquery version "1.0" encoding "UTF-8";

(: A script to generate select boxes for searching by keys such as opus numbers numbers or names. :)
(: The generated code needs to be cleaned manually, though :)

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

declare variable $database := "/db/public";
declare variable $coll := request:get-parameter("c","HartW");


declare function loop:clean-names ($key as xs:string) as xs:string
{
  (: strip off any text not part of the name (marked with a comma or parentheses) :)
  let $txt := concat(translate(normalize-space($key),',;(','***'),'*')
  return substring-before($txt,'*') 
};

declare function loop:invert-names ($key as xs:string) as xs:string
{
  let $k := loop:clean-names($key)
  (: put last name first :)
  let $txt := 
  
  if(contains($k,' ')) then
    (: concat(normalize-space(substring-after($key,' ')),', ', normalize-space(substring-before($key,' ')))   :)
    concat(substring($k,
                    index-of(string-to-codepoints($k), 
                             string-to-codepoints(' ')
                             )[last()] +1,
                    string-length($k)                             
                   ),
    ', ',
    substring($k,
                    1, 
                    index-of(string-to-codepoints($k), 
                             string-to-codepoints(' ')
                             )[last()] -1
                   )
     )       
  else 
    $k 
  return $txt 
};

declare function loop:simplify-list ($key as xs:string) as xs:string
{
  (: strip off anything following the first volume reference :)
  let $txt := concat(translate(normalize-space($key),' ,;()-–/','********'),'*')
  return substring-before($txt,'*')
};


declare function loop:padded-numbers ($key as xs:string) as xs:string
{
  (: pad string values with "0"s up to a certain length to get the right sort order :)
  let $txt := concat("00000000000000000000",$key)
  return substring($txt,string-length($key)+1,20)
};




<html xmlns="http://www.w3.org/1999/xhtml">
	<body>
	
	
	    <div>
        Names: <select name="names">
        <option value=""/>
		    {
            	    for $c in distinct-values(
            		collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $coll]//(m:persName | m:author | m:recipient)[not(name(..)='respStmt' and name(../..)='pubStmt' and name(../../..)='fileDesc')]
            		/normalize-space(loop:clean-names(normalize-space(string()))[string-length(.) > 0 and not(contains(.,'Carl Nielsen'))]))
                    order by loop:invert-names($c)
            	    return 
            	       <option value="{$c}">{loop:invert-names($c)}</option>
            }
        </select>
    </div>


	
	
    <div>
		
        {data($coll)}: 
        <select name="{lower-case($coll)}">
            <option value=""/>
    		    {
                	    for $c in distinct-values(
                		collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $coll]/m:workList/m:work/m:identifier[@label=$coll]/string()[string-length(.) > 0])
                        order by loop:padded-numbers($c)
                	    return 
                	       <option value="{$c}">{$c}</option>
                }
       </select>
   </div>
   
   
   <div>
        Opus: 
        <select name="opus">
            <option value=""/>
    		    {
                	    for $c in distinct-values(
                		collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $coll]/m:workList/m:work/m:identifier[@label='Opus']/string()[string-length(.) > 0])
                        order by number(translate($c,'abcdefghijklmnopqrstuvwxyz',''))
                	    return 
                	       <option value="{$c}">{$c}</option>
                }
       </select>

    </div>

    <div><!--
RISM sigla: 
        <select name="rism">
        <option value=""/>
		    {
            	    for $c in distinct-values(
            		collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $coll]//m:identifier[@authority='RISM']/string()[string-length(.) > 0])
                    order by $c
            	    return 
            	       <option value="{$c}">{$c}</option>

            }
        </select>-->
    </div>

  </body>
</html>

