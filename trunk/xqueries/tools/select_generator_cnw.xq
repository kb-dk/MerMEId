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

declare variable $database := "/db/cnw/data";


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



<html xmlns="http://www.w3.org/1999/xhtml">
	<body>
	
	
	    <div>
        Names: <select name="names">
        <option value=""/>
		    {
            	    for $c in distinct-values(
            		collection($database)//(m:persName | m:author | m:recipient)[not(name(..)='respStmt' and name(../..)='pubStmt' and name(../../..)='fileDesc')]
            		/loop:clean-names(normalize-space(string()))[string-length(.) > 0 and not(contains(.,'Carl Nielsen'))])
                    order by loop:invert-names($c)
            	    return 
            	       <option value="{$c}">{loop:invert-names($c)}</option>

            }
        </select>
    </div>


	
	
        <div>
		
CNW: <select name="cnw">
        <option value=""/>
		    {
            	    for $c in distinct-values(
            		collection($database)//m:workList/m:work/m:identifier[@label='CNW']/string()[string-length(.) > 0 and translate(.,'0123456789','')=''])
                    order by number($c)
            	    return 
            	       <option value="{$c}">{$c}</option>

            }
       </select>
       
Opus: <select name="opus">
        <option value=""/>
		    {
            	    for $c in distinct-values(
            		collection($database)//m:workList/m:work/m:identifier[@label='Opus']/string()[string-length(.) > 0])
                    order by number(translate($c,'abcdefghijklmnopqrstuvwxyz',''))
            	    return 
            	       <option value="{$c}">{$c}</option>

            }
       </select>

FS: <select name="fs">
        <option value=""/>
		    {
            	    for $c in distinct-values(
            		collection($database)//m:workList/m:work/m:identifier[@label='FS']/loop:simplify-list(string())[string-length(.) > 0])
                    order by number(translate(loop:simplify-list($c),'abcdefghijklmnopqrstuvwxyz','')), translate(loop:simplify-list($c),'01234567890','') 
            	    return 
            	       <option value="{$c}">{$c}</option>

            }
       </select>
<!--
CNS: <select name="cns">
        <option value=""/>
		    {
            	    for $c in distinct-values(
            		collection($database)//m:workList/m:work/m:identifier[@label='CNS']/string()[string-length(.) > 0])
                    order by number($c)
            	    return 
            	       <option value="{$c}">{$c}</option>

            }
       </select>
       
CNU: <select name="cnu">
        <option value=""/>
        <option value="I/1–3">I/1–3</option>
        <option value="I/4–5">I/4–5</option>
        <option value="II/1">II/1</option>
        <option value="II/2">II/2</option>
        <option value="II/3">II/3</option>
        <option value="II/4">II/4</option>
        <option value="II/5">II/5</option>
        <option value="II/6">II/6</option>
        <option value="II/7">II/7</option>
        <option value="II/8">II/8</option>
        <option value="II/9">II/9</option>
        <option value="II/10">II/10</option>
        <option value="II/11">II/11</option>
        <option value="II/12">II/12</option>
        <option value="III/1">II/1</option>
        <option value="III/2">II/2</option>
        <option value="III/3">II/3</option>
        <option value="III/4">II/4</option>
        <option value="III/5">II/5</option>
        <option value="III/6">II/6</option>
        <option value="IV/1">IV/1</option>
      </select>
      -->
    </div>

    <div><!--
RISM sigla: 
        <select name="rism">
        <option value=""/>
		    {
            	    for $c in distinct-values(
            		collection($database)//m:identifier[@authority='RISM']/string()[string-length(.) > 0])
                    order by $c
            	    return 
            	       <option value="{$c}">{$c}</option>

            }
        </select>-->
    </div>

  </body>
</html>

