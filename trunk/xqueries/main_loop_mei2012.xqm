xquery version "1.0" encoding "UTF-8";
module namespace loop="http://kb.dk/this/getlist";

declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace ft="http://exist-db.org/xquery/lucene";

declare function loop:getlist (
  $coll  as xs:string,
  $query as xs:string) as node()* {

  let $list  := 
    if(fn:string-length($coll)>0 and not($coll='all') ) then 
      if($query) then
	for $doc in collection("/db/dcm")/m:mei[m:meihead/m:encodingdesc/m:projectdesc/m:p/m:list[@n='use']/m:item/string()=$coll and ft:query(.,$query)] 
	order by $doc/m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='composer'][1],$doc/m:meihead/m:filedesc/m:titlestmt/m:title[@type='main'][1]
	return $doc 
      else
	for $doc in collection("/db/dcm")/m:mei[m:meihead/m:encodingdesc/m:projectdesc/m:p/m:list[@n='use']/m:item/string()=$coll] 
	order by $doc/m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='composer'][1],$doc/m:meihead/m:filedesc/m:titlestmt/m:title[@type='main'][1]
	return $doc 
    else
      if($query) then
        for $doc in collection("/db/dcm")/m:mei[ft:query(.,$query)]
	order by $doc/m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='composer'][1],$doc/m:meihead/m:filedesc/m:titlestmt/m:title[@type='main'][1]
	return $doc
      else
        for $doc in collection("/db/dcm")/m:mei
	order by $doc/m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='composer'][1],$doc/m:meihead/m:filedesc/m:titlestmt/m:title[@type='main'][1]
	return $doc

   return $list

};

		 
