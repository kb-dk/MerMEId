xquery version "1.0" encoding "UTF-8";

(: A simple MEI/Verovio score viewer :)

declare namespace xl="http://www.w3.org/1999/xlink";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";
declare namespace m="http://www.music-encoding.org/ns/mei"; 

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $document := request:get-parameter("doc", "");
declare variable $score_id := request:get-parameter("score_id", "");
declare variable $mode     := request:get-parameter("mode", "mei");


<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>View MEI score</title>
      <link rel="stylesheet" type="text/css" href="/editor/style/dcm.css"/>
      <script src="http://www.verovio.org/javascript/latest/verovio-toolkit-light.js" type="text/javascript">
    	<!-- verovio toolkit -->
      </script>
      <script type="text/javascript">
		/* Create the Verovio toolkit instance */
		var vrvToolkit = new verovio.toolkit();
		var mode = '{$mode}';
	  </script>
    </head>
    <body class="list_files">
      <div id="all">
          <div id="main">
             <div class="content_box">
    
        		<div id="score_container">
        		  <!-- score will be rendered here -->
        		  <p>Loading...</p>
        		</div>
        		
       			<!-- put the MEI incipit XML into the document here -->
        		<script type="text/xmldata" id="mei_score_data">
        		  { if ($mode = 'mei') then 

        			<mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="2013">
        				<music>
        					<body>
        						<mdiv>
        						{ 
        							let $list := 
                                        for $doc in collection("/db/dcm")
                                        where util:document-name($doc)=$document
                                        return $doc
                                    
                                    for $doc in $list
                                        return $doc//m:score[@xml:id=$score_id] 
                                }
        						</mdiv>
        					</body>
        				</music>
        			</mei>
                  else if ($mode = 'pae' or $mode = 'plaineAndEasie') then
                    let $list := 
                        for $doc in collection("/db/dcm")
                        where util:document-name($doc)=$document
                        return $doc
                    
                    for $doc in $list
                        return concat('@data:',$doc//m:incipCode[@xml:id=$score_id]) 
                  else ''
                  }
        		</script>
                
                <!-- use Verovio for rendering MEI incipits -->
        		<script type="text/javascript" src="/editor/js/render_score.js">
        		  <!-- the rendering js must be imported -->
        		</script>
                
            </div>
          </div>
      </div>
    </body>
</html>
