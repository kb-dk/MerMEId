xquery version "1.0" encoding "UTF-8";
module namespace loop="http://kb.dk/this/getlist";

declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace ft="http://exist-db.org/xquery/lucene";

declare function loop:pubstatus(
	$published_only  as xs:string,
	$doc as node())  as xs:boolean 
{
let $uri    := concat("/db/public/",util:document-name($doc))
let $status := not($published_only) or ($published_only and doc-available($uri))
return $status
};

declare function loop:getlist (
	$published_only  as xs:string,
	$coll            as xs:string,
	$query           as xs:string) as node()* 
{

        let $list  := 
        if($coll) then 
        if($query) then
        for $doc in collection("/db/dcm")/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll  and ft:query(.,$query)] 
        where loop:pubstatus($published_only,$doc)
	order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:respStmt/m:persName[1]/string(),$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1]/string()
	return $doc 
	else
	for $doc in collection("/db/dcm")/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll] 
        where loop:pubstatus($published_only,$doc)
	order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:respStmt/m:persName[1]/string()[1],$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1]/string()[1]
	return $doc 
        else
	if($query) then
        for $doc in collection("/db/dcm")/m:mei[ft:query(.,$query)]
        where loop:pubstatus($published_only,$doc)
	order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:respStmt/m:persName[1]/string()[1],$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1]/string()[1]
	return $doc
        else
        for $doc in collection("/db/dcm")/m:mei
        where loop:pubstatus($published_only,$doc)
	order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:respStmt/m:persName[1]/string()[1],$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1]/string()[1]
	return $doc
	
	return $list

};

