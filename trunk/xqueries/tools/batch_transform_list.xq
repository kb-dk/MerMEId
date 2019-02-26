xquery version "1.0" encoding "UTF-8";

declare namespace xl="http://www.w3.org/1999/xlink";
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

declare variable $coll   := request:get-parameter("coll",    "") cast as xs:string;
declare variable $query  := request:get-parameter("query","") cast as xs:string;
declare variable $xsl  := xs:anyURI(request:get-parameter("xsl",""));
declare variable $database := request:get-parameter("db","/db/dcm");

declare variable $local:sortby     := "null,work_number";

declare function local:getlist (
  $database        as xs:string,
  $coll            as xs:string,
  $query           as xs:string) as node()* 
  {
    let $sortby := request:get-parameter("sortby",$local:sortby)
    let $sort0  := substring-before($sortby,",")
    let $sort1  := substring-after($sortby,",")
    let $list   := 
      if($coll) then 
	if($query) then
      for $doc in collection($database)/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll  and ft:query(.,$query)] 
	    order by local:sort-key ($doc,$sort0),local:sort-key($doc,$sort1)
	  return $doc 
	else
	  for $doc in collection($database)/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll] 
	    order by local:sort-key ($doc,$sort0),local:sort-key($doc,$sort1)
	  return $doc 
    else
	  if($query) then
        for $doc in collection($database)/m:mei[ft:query(.,$query)]
	      order by local:sort-key ($doc,$sort0),local:sort-key($doc,$sort1)
	    return $doc
    else
      for $doc in collection($database)/m:mei
	    order by local:sort-key ($doc,$sort0),local:sort-key($doc,$sort1)
	  return $doc
	      
    return $list

  };



declare function local:sort-key (
  $doc as node(),
  $key as xs:string) as xs:string
{

  let $collection:=$doc//m:seriesStmt/m:identifier[@type="file_collection"]/string()[1] 

  let $sort_key:=
    if($key eq "title") then
      replace(lower-case($doc//m:workList/m:work/m:title[1]/string()),"\\\\ ","")
    else if($key eq "date") then
      substring($doc//m:workList/m:work/m:history/m:creation/m:date/(@notafter|@isodate|@enddate|@startdate|@notbefore)[1],1,4)
    else if($key eq "work_number") then
      let $identifier:=$doc//m:workList/m:work/m:identifier[@label=$collection][1]/string()
      (: extract any trailing number :)
      let $number:= replace($identifier,'^.*?(\d*)$','$1')
      (: and anything that might be before the number :)
      let $prefix:= replace($identifier,'^(.*?)\d*$','$1')
      (: make the number a 15 character long string padded with zeros :)
      let $padded_number:=concat("0000000000000000",normalize-space($number))
      let $len:=string-length($padded_number)-14
	return concat($prefix,substring($padded_number,$len,15))
    else 
      ""
  return $sort_key
};


declare function local:get-work-number($doc as node() ) as xs:string* {
  let $c := $doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"][1]/string()
  let $no := $doc//m:meiHead/m:workList/m:work[1]/m:identifier[@label=$c][1]/string()
  return ($c, $no)	
};

let $list := local:getlist($database, $coll, $query)

return 
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Documents to transform</title>
    <link rel="stylesheet" type="text/css" href="/editor/style/dcm.css"/>
    <link rel="stylesheet" type="text/css" href="/editor/style/public_list_style.css"/>
    <link rel="styleSheet" type="text/css" href="/editor/style/list_style.css"/>
    <link rel="styleSheet" type="text/css" href="/editor/style/xform_style.css"/>
</head>
<body class="list_files">
<div id="all">
    <div id="main">
        <h1>Batch transform XML files in the database</h1>  
            {
            let $exists :=
            if (not(doc-available($xsl))) then
                <p class="warning" style="color: red">The file {$xsl} is not available</p>
            else 
                <div>
                    <p>XSL stylesheet: {$xsl}</p>
                    <p>{count($list)} file(s) will be transformed. </p>
                    <form method="get" action="batch_transform.xq">
                        <input type="hidden" name="xsl" value="{$xsl}"/>
                        <input type="hidden" name="coll" value="{$coll}"/>
                        <input type="hidden" name="query" value="{$query}"/>
                        <input type="hidden" name="db" value="{$database}"/>
                        <input type="submit" value="Transform!"/>
                    </form>
                    <p class="warning" style="color: red">Warning! This will transform all of the files listed below and cannot be undone.<br/> 
                    Please make sure to save a copy of your data  
                    for backup before batch transforming.</p>
                    <p>&#160;</p>
                    <p id="list_closed" style="display:none;">
                        <input type="button" onclick="getElementById('list_open').style.display='block'; getElementById('list_closed').style.display='none';" value="Show list"/>
                    </p>
                    <div id="list_open">
                        <p><input type="button" onclick="getElementById('list_open').style.display='none'; getElementById('list_closed').style.display='block';" value="Hide list"/></p>
                        <table cellpadding="2" cellspacing="0" border="0" style="width: auto;">
                            <tr><th>Work no.&#160;</th><th>Title&#160;</th><th>File</th></tr>
                            {
                              for $doc in $list
                              let $html := 
                              <tr>
                                 <td>{local:get-work-number($doc)} &#160;</td>
                                 <td><a href="{concat("http://",request:get-header('HOST'),"/storage/present.xq?doc=",substring-after(document-uri(root($doc)),$database))}" 
                                    target="_blank" title="HTML preview">{$doc/m:meiHead/m:fileDesc/m:titleStmt/m:title[1]/string()}</a> &#160;</td>
                                 <td><a href="{concat("http://",request:get-header('HOST'),replace(document-uri(root($doc)),'/db/','/storage/'))}" 
                                    target="_blank" title="XML">{substring-after(document-uri(root($doc)),$database)}</a></td>
                              </tr>
                              
                              return $html
                            }   
                        </table>
                    </div>
                </div>
            return $exists
            }
        </div>
    </div>
</body>
</html>


