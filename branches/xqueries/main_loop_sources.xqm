xquery version "1.0" encoding "UTF-8";
module namespace list="http://kb.dk/this/getlist-sources";

declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace ft="http://exist-db.org/xquery/lucene";

declare function list:getlist ($coll  as xs:string,
                               $query as xs:string) as node()* 

{
  let $list  := 
    if($coll) then 
      if($query) then
	for $doc in collection("/db/dcm")/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll and string-length(string-join(m:meiHead/m:fileDesc/m:sourceDesc/m:source/m:titleStmt/m:title,""))>0 and ft:query(.,$query)] 
	order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:respStmt/m:persName[1]/string(),$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:title[1]/string()
	return $doc 
      else
	for $doc in collection("/db/dcm")/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll and string-length(string-join(m:meiHead/m:fileDesc/m:sourceDesc/m:source/m:titleStmt/m:title,""))>0 ] 
	order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:respStmt/m:persName[1]/string(),$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:title[1]/string()

	return $doc 
      else
	if($query) then
          for $doc in collection("/db/dcm")/m:mei[ft:query(.,$query) and string-length(string-join(m:meiHead/m:fileDesc/m:sourceDesc/m:source/m:titleStmt/m:title,""))>0 ]
	  order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:respStmt/m:persName[1]/string(),$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:title[1]/string()
	  return $doc
        else
          for $doc in collection("/db/dcm")/m:mei[string-length(string-join(m:meiHead/m:fileDesc/m:sourceDesc/m:source/m:titleStmt/m:title,""))>0]
	  order by $doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:respStmt/m:persName[1]/string(),$doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt/m:title[1]/string()
	  return $doc
	      
  return $list

};


declare function list:get-reverse-links($target as xs:string) as node()*  
{

  let $list  := 
  for $doc in collection("/db/dcm")/m:mei[m:meiHead//m:source[@target=$target]]
  return $doc

  return $list

};
