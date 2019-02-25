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


declare function local:format-main-title ($key as xs:string) as node()
{
  let $txt :=
  if(fn:contains($key,', opus')) then
    <span>
        <i>{fn:substring-before($key,', opus')}</i>
        {fn:concat(', opus',fn:substring-after($key,', opus'))}
    </span>
  else 
    <i>{$key}</i>
  return $txt 
};


<html xmlns="http://www.w3.org/1999/xhtml">
	<body>

    <h1>Titles and alternative titles</h1>
    {
    if($collection="") then
       <p>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
       (for instance, ?c=CNW) to the URL</p>
    else 
    
    <div>
        <h2>Format: <i>Title</i> Subtitle (Alternative title)</h2>
        <p><small>[Titles are not italicized if 1) the work&apos;s list of keywords (termList) includes the word &apos;Song&apos; and 2) there is no
        alternative title; in that case, the title is interpreted as the song&apos;s first line and therefore not italicized]</small></p>
        <div>
                
    		    {
    
                	    for $c in collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type eq "file_collection"]  eq $collection]/m:workList/m:work
                        order by lower-case($c/m:titleStmt/m:title[1]/string()), lower-case($c/m:titleStmt/m:title[@type='subordinate'][1]/string()), lower-case($c/m:titleStmt/m:title[@type='alternative'][1]/string())
                	    return
                	       <div>
                	       {
                	           (: title (first line) :)
                                let $output := 
                                   if(not($c/m:titleStmt/m:title[@type='alternative']) and $c/m:classification/m:termList/m:term='Song'
                	               and not(fn:contains($c/m:identifier[@label=$collection],'Coll.'))) then
                	                   (: song with no alternative title, i.e. title is first line :)
                                    fn:concat($c/m:titleStmt/m:title[@type='main' or not(@type)][1]/string(),' ',
                                    $c/m:titleStmt/m:title[@type='subordinate'][1]/string()) 
                        	       else
                                    <span>
                                        {local:format-main-title($c/m:titleStmt/m:title[@type='main' or not(@type)][1]/string())}
                                        {let $alt:=
                                            if($c/m:titleStmt/m:title[@type='alternative']) then 
                                                fn:concat(' (',$c/m:titleStmt/m:title[@type='alternative'][1]/string(),') ')
                                            else
                                                ''
                                         return fn:concat(' ',$c/m:titleStmt/m:title[@type='subordinate'][1]/string(),$alt)}
                                    </span>
                                return $output
                             }
                             { fn:concat(' &#160; ',$collection,' ',$c/m:identifier[@label=$collection]/string())}
                             </div>
    
                }
        </div>
    
        <h2>Alternative title (<i>Title</i>)</h2>
        <div>
                
    		    {
                	    for $c in collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type eq "file_collection"]  eq $collection]/m:workList/m:work[m:titleStmt/m:title[@type='alternative']]
                        order by lower-case($c/m:titleStmt/m:title[@type='alternative'][1]/string()), lower-case($c/m:titleStmt/m:title[1]/string()) 
                	    return
                	       <div>
                	       {
                	           (: first line (title) :)
                                let $output := 
                                    <span>
                                       {fn:concat($c/m:titleStmt/m:title[@type='alternative'][1]/string(),' (')}
                                       {local:format-main-title($c/m:titleStmt/m:title[@type='main' or not(@type)][1]/string())}
                                       {let $sub:=
                                        if(fn:string-length($c/m:titleStmt/m:title[@type='subordinate'][1]/string()) > 0) then
                                            fn:concat(' ',$c/m:titleStmt/m:title[@type='subordinate'][1]/string())
                                        else
                                            ''
                                        return fn:concat($sub,')') 
                                       }
                                    </span>
    
                                return $output
                             }
                             { fn:concat(' &#160; ',$collection,' ',$c/m:identifier[@label=$collection]/string())}
                             </div>
    
                }
        </div>
    </div>
    }
  </body>
</html>
