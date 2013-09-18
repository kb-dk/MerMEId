xquery version "1.0" encoding "UTF-8";
module namespace loop="http://kb.dk/this/getlist";

declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace util="http://exist-db.org/xquery/util";

declare function loop:genre-filter(
  $genre as xs:string,
  $doc as node()) as xs:boolean
{
  let $occurrence :=
    if( string-length($genre)=0) then
      true()
    else 
      count($doc//m:workDesc[contains(m:work/m:classification/m:termList/m:term/string(),$genre) ])>0
      return $occurrence
};


declare function loop:pubstatus(
	$published_only  as xs:string,
	$doc as node())  as xs:boolean 
{
  let $uri         := concat("/db/public/",util:document-name($doc))
  let $dcm_hash    := util:hash($doc,'md5')

  let $status := 
    if( not($published_only) ) then
      true()
    else
      if( doc-available($uri)) then
	let $public_hash := util:hash(doc($uri),'md5')
	return
	if ($published_only eq 'pending' and $public_hash ne $dcm_hash) then
	  true()
	else 
	  if($published_only eq 'any') then
	    true()
	  else
	    false()
      else
	if($published_only eq 'unpublished') then
	  true()
	else 
	  false()

   return $status

};

declare function loop:getlist (
  $database        as xs:string,
  $published_only  as xs:string,
  $coll            as xs:string,
  $genre           as xs:string,
  $query           as xs:string) as node()* 
{

        let $list  := 
        if($coll) then 
        if($query) then
        for $doc in collection($database)/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll  and ft:query(.,$query)] 
	  let $sort_key_person := replace(lower-case($doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:respStmt/m:persName[1]/string()),"\\\\ ","")
	  let $sort_key_title := replace(lower-case($doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1]/string()),"\\\\ ","")
        where loop:pubstatus($published_only,$doc) and loop:genre-filter($genre,$doc)
	order by $sort_key_person,$sort_key_title
	return $doc 
	else
	for $doc in collection($database)/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll] 
	  let $sort_key_person := replace(lower-case($doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:respStmt/m:persName[1]/string()),"\\\\ ","")
	  let $sort_key_title := replace(lower-case($doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1]/string()),"\\\\ ","")
          where loop:pubstatus($published_only,$doc) and loop:genre-filter($genre,$doc)
	  order by $sort_key_person,$sort_key_title
	return $doc 
        else
	if($query) then
        for $doc in collection($database)/m:mei[ft:query(.,$query)]
	  let $sort_key_person := replace(lower-case($doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:respStmt/m:persName[1]/string()),"\\\\ ","")
	  let $sort_key_title := replace(lower-case($doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1]/string()),"\\\\ ","")
        where loop:pubstatus($published_only,$doc) and loop:genre-filter($genre,$doc)
	order by $sort_key_person,$sort_key_title
	return $doc
        else
        for $doc in collection($database)/m:mei
	  let $sort_key_person := replace(lower-case($doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:respStmt/m:persName[1]/string()),"\\\\ ","")
	  let $sort_key_title := replace(lower-case($doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1]/string()),"\\\\ ","")
        where loop:pubstatus($published_only,$doc) and loop:genre-filter($genre,$doc)
	order by $sort_key_person,$sort_key_title
	return $doc
	
	return $list

};

