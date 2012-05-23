xquery version "1.0" encoding "UTF-8";

(: Search the a mei document store and return links to the atom feed :)

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace app="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace dc="http://purl.org/dc/elements/1.1/";

declare variable $host_port_context :=  "distest.kb.dk";
declare variable $subject   := request:get-parameter("subject",   "");
declare variable $items     := request:get-parameter("itemsPerPage","");

declare option exist:serialize "method=xml media-type=text/xml"; 

<opml>
  <head>
    <title>
    </title>
  </head>
  <body>
    <outline 
       text="All works" 
       xmlUrl="http://distest.kb.dk/storage/atom_feed.xq" 
       htmlUrl="http://{$host_port_context}/data/biblio/2012/jan/dcm/"
       nodeId="all"
       id="all">
      {
	let $itemsarg := 
	  if($items) then 
	    fn:concat("&amp;itemsPerPage=",$items)
	  else
	    ""

	for $c in distinct-values(
	  collection("/db/dcm")/m:mei/m:meihead/m:encodingdesc/m:projectdesc/m:p/m:list[@n='use']/m:item/string())
	  where fn:string-length($c)>0
	  return
	  <outline
          xmlUrl="http://distest.kb.dk/storage/atom_feed.xq?page=1{$itemsarg}&amp;subject={$c}" text="{$c}" 
	  htmlUrl="http://{$host_port_context}/data/biblio/2012/jan/dcm/en/?subject={$c}{$itemsarg}"
	  id="{$c}"
	  nodeId="{$c}"
	  />

      }
    </outline>
  </body>
</opml>
