<%@page contentType="text/html;charset=UTF-8"%>
<%@page import="java.io.*"%>
<%@page import="org.apache.log4j.*"%>
<%

// This script does just one thing. When called it reads a URI from the
// request and it will then retrieve the corresponding content and parse it
// under the assumption that it is a well formed XML document. The parser is
// then executing all XInclude statements in the document.
//
// The whole lot is then deliverd via the response object.

request.setCharacterEncoding("UTF-8");

response.setContentType("text/xml");
response.setCharacterEncoding("UTF-8");

java.io.PrintWriter printout = response.getWriter();

java.lang.Long start = System.currentTimeMillis();
Logger logger = Logger.getRootLogger();

String pathInfo    = request.getPathInfo(); 
String uri         = request.getParameter("uri");
String queryString = request.getQueryString();
String newRequest  = queryString;

if(logger.isInfoEnabled()){ 
    logger.info("Sending request: " + uri); 
}

org.w3c.dom.Document form = null;
javax.xml.parsers.DocumentBuilder dBuilder = null;

javax.xml.parsers.DocumentBuilderFactory dfactory  =
    javax.xml.parsers.DocumentBuilderFactory.newInstance();

System.out.println("created dfactory");

dfactory.setNamespaceAware(true);
dfactory.setXIncludeAware(true);
dBuilder = dfactory.newDocumentBuilder();
form = dBuilder.parse(uri);
logger.info("done parsing");
serialize(form,printout);

java.lang.Long completed = System.currentTimeMillis() - start;
      
if(logger.isInfoEnabled()){ 
    logger.info(".. work done in " + completed + " ms"); 
}

%>



<%!

    void serialize(org.w3c.dom.Document doc, java.io.PrintWriter out) {

    try {

	org.w3c.dom.bootstrap.DOMImplementationRegistry registry =
	    org.w3c.dom.bootstrap.DOMImplementationRegistry.newInstance();

	org.w3c.dom.ls.DOMImplementationLS impl =
	    (org.w3c.dom.ls.DOMImplementationLS) registry.getDOMImplementation("LS");

	org.w3c.dom.ls.LSSerializer serializer = impl.createLSSerializer();

	org.w3c.dom.ls.LSOutput output = impl.createLSOutput( );
	output.setEncoding("UTF-8");
	output.setCharacterStream( out ); 
	logger.info("after setting character stream " + output.getEncoding());
	serializer.write(doc,output);
	logger.info(".. serialized and written to output");
	return;

    } catch (java.lang.ClassNotFoundException classNotFound) {
	logger.error(classNotFound.getMessage());
    } catch (java.lang.InstantiationException instantiationPrblm) {
	logger.error(instantiationPrblm.getMessage());
    } catch (java.lang.IllegalAccessException accessPrblm) {
	logger.error(accessPrblm.getMessage());
    }
    return;
  }


%>
