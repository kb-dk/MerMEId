package dk.kb.mermeid.filter;

/**
 * This servlet implements a filter like HTTP proxy
 * @author Sigfrid Lundberg (slu@kb.dk)
 * @version $Revision$
 * Last modified $Date$
 */
public class FilterUtilityMethods  {

    /*

      The filter is addressed using a context root ending with something
      stored in "filter" parameter in the http_filter.xml. Typically "filter/"
      
      A MerMEId record is typically retrieved using filter/dcm/filname.xml

      We will refer to "filter" as context "dcm" as database and filename.xml
      as "record"

    */

    private String database = "";
    private String record   = "";

    private javax.xml.parsers.DocumentBuilderFactory dfactory  =
	javax.xml.parsers.DocumentBuilderFactory.newInstance();

    private javax.xml.transform.TransformerFactory trans_fact  = 
	javax.xml.transform.TransformerFactory.newInstance();

    private org.apache.log4j.Logger logger = 
	org.apache.log4j.Logger.getLogger(
			 FilterUtilityMethods.class.getPackage().getName());

    private java.util.Properties props = null;
    private java.lang.Long       start = null;

    public FilterUtilityMethods() {
	this.props = Configuration.getInstance().getConstants();
    }

    /**
     * HTTP GET
     * This method sends a request, collects what is returned, xslt transforms
     * that and return it to the client
     */
    public void recieveAndFilterData(javax.servlet.http.HttpServletRequest  request,
				      javax.servlet.http.HttpServletResponse response  ) 
	throws java.io.IOException 
    {

	String newRequest  = this.uriConstructor(request,response);

	java.lang.String    mime    = this.props.getProperty("get.mime");
	java.lang.String    charset = this.props.getProperty("get.charset");

	request.setCharacterEncoding("UTF-8");

	org.apache.commons.httpclient.HttpClient httpClient = 
	    new org.apache.commons.httpclient.HttpClient();

	httpClient.getHttpConnectionManager().getParams().setConnectionTimeout(5000);

	//if(logger.isInfoEnabled()){ 
	logger.debug("Sending request: " + newRequest); 
	//}

	//create a method object
	org.apache.commons.httpclient.methods.GetMethod get_method = 
	    new org.apache.commons.httpclient.methods.GetMethod(newRequest);

	get_method.setFollowRedirects(true);
	httpClient.executeMethod(get_method);

	org.apache.commons.httpclient.Header[] clientResponseHeaders = 
	    get_method.getResponseHeaders();

	int status = get_method.getStatusLine().getStatusCode();

	logger.debug("response status:\t" + 
		    status + 
		    " (" + get_method.getStatusLine().toString()  + ")"); 
	
	for(int i=0;i<clientResponseHeaders.length;i++) {
	    logger.info("response:\t" + clientResponseHeaders[i].toExternalForm()); 
	}

	java.io.InputStream in      = get_method.getResponseBodyAsStream();

	if(status == 200) {
	    response.setContentType(mime);
	    response.setCharacterEncoding(charset);
	    java.io.Writer out      = response.getWriter();
	    this.doTransform(this.props.getProperty("get." + this.getBase()),in,out);
	    out.flush();
	} else {
	    response.setContentType("text/plain");
	    response.setCharacterEncoding(charset);
	    response.setStatus(status);
	}

	in.close();
	this.workDone();

    }    

    /**
     * Here we recieve data wia a PUT request. We xslt transform these data
     * and forward them somewhere else on the net again using a PUT
     */
    public void filterAndSubmitData(javax.servlet.http.HttpServletRequest  request,
				     javax.servlet.http.HttpServletResponse response  ) 
	throws java.io.IOException 
    {

	String targetUri  = this.uriConstructor(request,response);	

	org.apache.commons.httpclient.HttpClient httpClient = 
	    new org.apache.commons.httpclient.HttpClient();

	httpClient.getHttpConnectionManager().getParams().setConnectionTimeout(5000);

	httpClient.getParams().setParameter("http.protocol.single-cookie-header", true);
	httpClient.getParams().setCookiePolicy(
        org.apache.commons.httpclient.cookie.CookiePolicy.BROWSER_COMPATIBILITY );

	logger.debug("Sending request to URI: " + targetUri); 

	//create a method object
	org.apache.commons.httpclient.methods.PutMethod put_method =
	    new org.apache.commons.httpclient.methods.PutMethod();

	java.io.InputStream  in      = request.getInputStream();
	java.io.StringWriter outdata = new java.io.StringWriter();
	java.io.Writer  out          = response.getWriter();

	this.doTransform(this.props.getProperty("put." + this.getBase()),in,outdata);

	String result      = outdata.getBuffer().toString();  

	String contentType = this.props.getProperty("put.mime");

        org.apache.commons.httpclient.
	    methods.
	    RequestEntity entity = 
	    new org.apache.commons.httpclient.
	    methods.StringRequestEntity(result,
					contentType,
					null);
	
	logger.debug(".. result\n" + result);

	this.setCredentials(request,httpClient);

	put_method.setRequestEntity(entity);
	put_method.setRequestHeader("Content-Type",contentType);

	put_method.setPath(targetUri);
	logger.debug("creating object: " + put_method.getPath());

	put_method.setFollowRedirects(false);
	httpClient.executeMethod(put_method);

	// We read data from the request

	in.close();

	put_method.releaseConnection();

	org.apache.commons.httpclient.Header[] responseHeaders = 
	    put_method.getResponseHeaders();

	int status = put_method.getStatusLine().getStatusCode();

	response.sendError(status, put_method.getStatusLine().toString());
	if(logger.isInfoEnabled()) {
	    logger.info("response status:\t" + 
			status + 
			" (" + put_method.getStatusLine().toString()  + ")"); 
	}

	for(int i=0;i<responseHeaders.length;i++) {

	    if(logger.isInfoEnabled()) {
		logger.info("response:\t" + responseHeaders[i].toExternalForm()); 
	    }

	}

	String responseBody = put_method.getResponseBodyAsString();
	this.workDone();

    }    


    public void doTransform(String xsl_name, 
			     java.io.InputStream in,
			     java.io.Writer out)
	throws java.io.IOException
    {

	logger.debug("start of doTransform");
	logger.debug("xslt script: " + xsl_name);
        org.w3c.dom.Document source_dom = null;
        javax.xml.parsers.DocumentBuilder dBuilder = null;

        try {
            dfactory.setNamespaceAware(true);
            dBuilder = dfactory.newDocumentBuilder();
            logger.debug("we start the parser");
            source_dom = dBuilder.parse(in);
            logger.debug("we've parsed the stuff");
        } catch (javax.xml.parsers.ParserConfigurationException parserPrblm) {
            logger.error(parserPrblm.getMessage());
        } catch (org.xml.sax.SAXException xmlPrblm) {
            logger.error(xmlPrblm.getMessage());
        }

	logger.debug("We've parsed it and survived try catch");

	javax.xml.transform.dom.DOMSource source = 
	    new javax.xml.transform.dom.DOMSource(source_dom);

	logger.debug("We've got source DOM");

	javax.xml.transform.dom.DOMResult result = 
	    new javax.xml.transform.dom.DOMResult();

	logger.debug("We've result");

	javax.xml.transform.stream.StreamSource xsl_source =
	    new javax.xml.transform.stream.StreamSource(xsl_name);

	logger.debug("We've got the xsl");

	try {
	    javax.xml.transform.Transformer transformer = 
		this.trans_fact.newTransformer(xsl_source);
	    if(xsl_source == null) {
		logger.debug("xsl_source null");
	    }
	    if(transformer == null) {
		logger.debug("transformer  null");
	    } else {
		logger.debug("we've made transformer");
	    }

	    transformer.transform(source, result); 

            logger.debug("we've transformed it");
	} catch(javax.xml.transform.TransformerConfigurationException tfCfgPrblm) {
	    logger.error(tfCfgPrblm.getMessage());
	} catch(javax.xml.transform.TransformerException tfPrblm) {
	    logger.error(tfPrblm.getMessage());
	}

	logger.debug("we're about to return");

	this.serialize( (org.w3c.dom.Document)result.getNode(), out );
	
    }

    public void workDone() {
	java.lang.Long completed = System.currentTimeMillis() - this.start;
	if(logger.isInfoEnabled()){ 
	    logger.info(".. work done in " + completed + " ms"); 
	}
    }

    public void serialize(org.w3c.dom.Document doc,
			  java.io.Writer  out ) {
        try {
            org.w3c.dom.bootstrap.DOMImplementationRegistry registry =
		org.w3c.dom.bootstrap.DOMImplementationRegistry.newInstance();

            org.w3c.dom.ls.DOMImplementationLS impl =
		(org.w3c.dom.ls.DOMImplementationLS) registry.getDOMImplementation("LS");

            org.w3c.dom.ls.LSSerializer serializer = impl.createLSSerializer();

	    org.w3c.dom.ls.LSOutput output = impl.createLSOutput( );
	    logger.debug("before setting encoding " + output.getEncoding());
	    output.setEncoding("UTF-8");
	    logger.debug("after setting encoding " + output.getEncoding());
	    output.setCharacterStream( out ); 
	    logger.debug("after setting character stream " + output.getEncoding());
	    serializer.write(doc,output);
	} catch (java.lang.ClassNotFoundException classNotFound) {
            logger.error(classNotFound.getMessage());
        } catch (java.lang.InstantiationException instantiationPrblm) {
            logger.error(instantiationPrblm.getMessage());
        } catch (java.lang.IllegalAccessException accessPrblm) {
            logger.error(accessPrblm.getMessage());
        }

    }

    public void setBase(String base) {
	this.database = base;
    }
    public String getBase() {
	return this.database;
    }

    public String getRecord() {
	return this.record;
    }

    public void setRecord(String record) {
	this.record = record;
    }



    public String uriConstructor(javax.servlet.http.HttpServletRequest  request,
				  javax.servlet.http.HttpServletResponse response ) {
	
	String http_method = request.getMethod();
	String pathInfo    = request.getPathInfo(); 
	String queryString = "";
	if(request.getQueryString() != null) {
	    queryString = "?" + request.getQueryString();
	}

	String host        = request.getServerName();
	int port           = request.getServerPort();
	if(port != 80) {
	    host = host + ":" + port;
	}

	java.lang.String context = this.props.getProperty("exist.context",null);
	String path              = "";

	// It seems that we need to access this on localhost on port 8080
	// or PUT won't work. Supposedly a configurable security limitation in eXist
	// I think it's good.

	String basedOn  = "";
	String protocol = "http://";
	if(context == null) {
	    basedOn     = "pathInfo";
	    path        = protocol + host + pathInfo;
	} else {

	    logger.info("uriConstructor pathInfo : " + pathInfo); 
	    logger.info("uriConstructor filter context : " + 
			this.props.getProperty("filter"));

	    String file = pathInfo.substring(
                                   pathInfo.lastIndexOf(
			                   this.props.getProperty("filter")));
	    String base = pathInfo.replaceAll("/([^/]+)$","");
	    this.setBase(base.replaceAll("/",""));

	    basedOn     = "context";

	    host        = this.props.getProperty("exist.host");

	    String portNumber = this.props.getProperty("exist.port");
	    logger.info("uriConstructor base : " + base); 
	    logger.info("uriConstructor file : " + file); 

	    logger.info("port number: " + portNumber); 

	    port        = java.lang.Integer.parseInt(portNumber);
	    path        = protocol + host + ":" + port + context + base + file;
	}
	

	String uri = path +  queryString;
	logger.info("constructed: " + uri + " based on " + basedOn); 
	return uri;

    }

    public void setCredentials(javax.servlet.http.HttpServletRequest    request,
				org.apache.commons.httpclient.HttpClient client) {

	java.lang.String realm    = this.props.getProperty("exist.realm");
	java.lang.String user     = this.props.getProperty("exist.user");
	java.lang.String password = this.props.getProperty("exist.password");

	java.lang.String host = this.props.getProperty("exist.host");
	int              port = 
	    java.lang.Integer.parseInt(this.props.getProperty("exist.port"));

	client.
	    getState().
	    setCredentials(
			   new org.apache.commons.
			   httpclient.auth.AuthScope(host,port,realm),
			   new org.apache.commons.httpclient.
			   UsernamePasswordCredentials(user,password)
			   ); 


	return;

    }

    void setStart(java.lang.Long start) {
	this.start = start;
    }

}
