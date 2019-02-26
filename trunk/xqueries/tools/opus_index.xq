xquery version "1.0" encoding "UTF-8";

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
(: the separator used for opus sub-numbers, e.g. Opus 27:2 :)
declare variable $separator := request:get-parameter("separator",":");

declare function local:get-title ($title as xs:string) as xs:string
{
  (: put last name first :)
  let $txt := 
  
    if(contains($title,'opus ')) then
      fn:substring-before($title, 'opus ')
    else
      if(contains($title,'Opus ')) then
        fn:substring-before($title, 'Opus ')
      else
        $title
        
  return $txt 
};

declare function local:numerical-value($opus) as xs:double {
    let $number := translate(translate($opus,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ',''),':,','..')
    return if(number($number) = number($number)) then number($number) else 1000
};

<html xmlns="http://www.w3.org/1999/xhtml">
	<body>
	
		<h2>Opus Numbers</h2>
		
		
		<table>
		    {
		          if($collection="") then
                    <tr><td>
                        <p>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
                        (for instance, ?c=CNW) to the URL</p>
                        <p>By default, a ':' in the opus number is interpreted as a sub-numbering separator. Change it by adding
                        a 'separator' parameter to the URL. Example: http://[your-server-name]/storage/tools/opus_index.xq?c=CNW&amp;separator=.
                        If the separator is recognized correctly, sub-numbers are indented.
                    </p>
                    </td></tr>
                  else 
		    
            	    for $c in collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection]/m:workList/m:work[m:identifier[normalize-space(@label)='Opus']]
                    order by local:numerical-value(normalize-space($c/m:identifier[normalize-space(@label)='Opus'][1]))
            	    return 
            	       <tr>
            	           <td>{
            	           if(contains($c/m:identifier[normalize-space(@label)='Opus'][1],$separator)) then
            	               ''
            	           else 
            	               $c/m:identifier[normalize-space(@label)='Opus'][1]
            	           }</td>
            	           <td>{
            	           if(contains($c/m:identifier[normalize-space(@label)='Opus'][1],$separator)) then
            	               <span>{fn:concat($c/m:identifier[normalize-space(@label)='Opus'][1],' ')}
                	               <i>{local:get-title($c/m:title[@type='main' or not(@type)][1])}</i>
            	               </span>
                           else
                                <i>{local:get-title($c/m:title[@type='main' or not(@type)][1])}</i>
                                }<!--</td>
            	           <td>-->{fn:concat(' &#160; ',$collection,' ',$c/m:identifier[@label=$collection]/string())}</td>
            	       </tr>

            }
        </table>
  </body>
</html>
