package dk.kb.mermeid.filter;

/**
 * This servlet implements a filter like HTTP proxy
 * @author Sigfrid Lundberg (slu@kb.dk)
 * @version $Revision$
 * Last modified $Date$
 */
public class HttpFilter extends javax.servlet.http.HttpServlet {

    private String uri_base = "/storage/dcm";

    private javax.xml.parsers.DocumentBuilderFactory dfactory  =
	javax.xml.parsers.DocumentBuilderFactory.newInstance();

    private javax.xml.transform.TransformerFactory trans_fact  = 
	javax.xml.transform.TransformerFactory.newInstance();

    private javax.servlet.ServletConfig            srvConf     = null;

    java.lang.Long start = null;

    private org.apache.log4j.Logger logger = 
	org.apache.log4j.Logger.getLogger(HttpFilter.class.getPackage().getName());

    private java.util.Properties props = null;

    public HttpFilter() {
	this.props = Configuration.getInstance().getConstants();
    }

    public void init(javax.servlet.ServletConfig srvConf) 
	throws javax.servlet.ServletException
    {
	this.srvConf = srvConf;
    }

    /**
     * <p>This one is used by the servlet container. God and servlet
     * container authors knows what it means</p>
     */
    public javax.servlet.ServletConfig getServletConfig() {
	return this.srvConf;
    }

    public void doGet(javax.servlet.http.HttpServletRequest request,
		      javax.servlet.http.HttpServletResponse response) 
	throws javax.servlet.ServletException, java.io.IOException 
    {        
	this.start = System.currentTimeMillis();
	logger.debug("Starting GET transaction ");
	this.recieveAndFilterData(request,response);
    }

    public void doPost(javax.servlet.http.HttpServletRequest request,
		       javax.servlet.http.HttpServletResponse response) 
	throws javax.servlet.ServletException, java.io.IOException
    {        
	this.start = System.currentTimeMillis();
	logger.debug("Starting POST transaction ");
	this.filterAndSubmitData(request,response);
    }

    public void doPut(javax.servlet.http.HttpServletRequest request,
		      javax.servlet.http.HttpServletResponse response) 
	throws javax.servlet.ServletException, java.io.IOException 
    {        
	this.start = System.currentTimeMillis();
	logger.debug("Starting PUT transaction ");
	this.filterAndSubmitData(request,response);
    }

    /**
     * HTTP GET
     * This method sends a request, collects what is returned, xslt transforms
     * that and return it to the client
     */
    private void recieveAndFilterData(javax.servlet.http.HttpServletRequest  request,
				      javax.servlet.http.HttpServletResponse response  ) 
	throws java.io.IOException 
    {

	java.lang.String    mime    = this.props.getProperty("get.mime");
	java.lang.String    charset = this.props.getProperty("get.charset");

	request.setCharacterEncoding("UTF-8");
	response.setContentType(mime);
	response.setCharacterEncoding(charset);

	String newRequest  = this.uriConstructor(request,response);

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
	java.io.Writer out          = response.getWriter();

	this.doTransform(this.props.getProperty("get"),in,out);

	out.flush();
	in.close();

	this.workDone();

    }    

    /**
     * Here we recieve data wia a PUT request. We xslt transform these data
     * and forward them somewhere else on the net again using a PUT
     */
    private void filterAndSubmitData(javax.servlet.http.HttpServletRequest  request,
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
	java.io.PrintWriter  out     = response.getWriter();

	this.doTransform(this.props.getProperty("put"),in,outdata);

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
	//	put_method.setRequestHeader("Accept",      contentType);

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
	//if(logger.isInfoEnabled()) {
        logger.info("response status:\t" + 
		    status + 
		    " (" + put_method.getStatusLine().toString()  + ")"); 
	//}

	for(int i=0;i<responseHeaders.length;i++) {

	    /*    
		  response.setHeader(responseHeaders[i].getName(),
		  responseHeaders[i].getValue());	    
	    */

	    if(logger.isInfoEnabled()) {
		logger.info("response:\t" + responseHeaders[i].toExternalForm()); 
	    }

	}

	String responseBody = put_method.getResponseBodyAsString();

	out.println("<!-- this is the answer from exist -->");
	out.println(responseBody);

	this.workDone();

    }    


    private void doTransform(String xsl_name, 
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

	logger.debug("We've source");

	javax.xml.transform.dom.DOMResult result = 
	    new javax.xml.transform.dom.DOMResult();

	logger.debug("We've result");

	javax.xml.transform.stream.StreamSource xsl_source =
	    new javax.xml.transform.stream.StreamSource(xsl_name);

	logger.debug("We've xsl");

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

    private void workDone() {
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
	    output.setEncoding("UTF-8");
	    output.setCharacterStream( out ); 
	    serializer.write(doc,output);
	} catch (java.lang.ClassNotFoundException classNotFound) {
            logger.error(classNotFound.getMessage());
        } catch (java.lang.InstantiationException instantiationPrblm) {
            logger.error(instantiationPrblm.getMessage());
        } catch (java.lang.IllegalAccessException accessPrblm) {
            logger.error(accessPrblm.getMessage());
        }

    }

    private String uriConstructor(javax.servlet.http.HttpServletRequest  request,
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
	// or PUT won't work.

	String basedOn  = "";
	String protocol = "http://";
	if(context == null) {
	    basedOn     = "pathInfo";
	    path        = protocol + host + pathInfo;
	} else {
	    String file = pathInfo.substring(pathInfo.lastIndexOf("/"));
	    basedOn     = "context";

	    host        = this.props.getProperty("exist.host");

	    String portNumber = this.props.getProperty("exist.port");
	    logger.info("port number: " + portNumber); 

	    port        = java.lang.Integer.parseInt(portNumber);
	    path        = protocol + host + ":" + port + context + file;
	}
	

	String uri = path +  queryString;

	logger.info("constructed: " + uri + " based on " + basedOn); 

	return uri;

    }

    private void setCredentials(javax.servlet.http.HttpServletRequest    request,
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

}
