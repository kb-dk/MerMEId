package dk.kb.mermeid.filter;

/**
 * This servlet implements a filter like HTTP proxy
 * @author Sigfrid Lundberg (slu@kb.dk)
 * @version $Revision$
 * Last modified $Date$
 */
public class DeleteServlet extends javax.servlet.http.HttpServlet {

    private javax.servlet.ServletConfig srvConf = null;
    private java.lang.Long                start = null;
    private java.util.Properties          props = null;
    private FilterUtilityMethods      utilities = new  FilterUtilityMethods();
    private org.apache.log4j.Logger logger = 
	org.apache.log4j.Logger.getLogger(
					  DeleteServlet.class.getPackage().getName());

    public DeleteServlet () {
	this.props = Configuration.getInstance().getConstants();
    }


    public void doGet(javax.servlet.http.HttpServletRequest request,
		      javax.servlet.http.HttpServletResponse response) 
	throws javax.servlet.ServletException, java.io.IOException 
    {        
	this.start = System.currentTimeMillis();
	request.setCharacterEncoding("UTF-8");

	org.apache.commons.httpclient.HttpClient httpClient = 
	    new org.apache.commons.httpclient.HttpClient();

	httpClient.getHttpConnectionManager().getParams().setConnectionTimeout(5000);

	httpClient.getParams().setParameter("http.protocol.single-cookie-header", true);
	httpClient.getParams().setCookiePolicy(
	       org.apache.commons.httpclient.cookie.CookiePolicy.BROWSER_COMPATIBILITY );

	String targetUri = this.utilities.uriConstructor(request,response);


	logger.debug("Sending request to URI: " + targetUri); 

	//create a method object
	org.apache.commons.httpclient.methods.DeleteMethod delete_method =
	    new org.apache.commons.httpclient.methods.DeleteMethod(targetUri);

	httpClient.executeMethod(delete_method);

	org.apache.commons.httpclient.Header[] clientResponseHeaders = 
	    delete_method.getResponseHeaders();

	int status = delete_method.getStatusLine().getStatusCode();

	java.lang.String text = "response status:\t" + status + 
		    " (" + delete_method.getStatusLine().toString()  + ")"; 
	
	for(int i=0;i<clientResponseHeaders.length;i++) {
	     text = text + "response:\t" + clientResponseHeaders[i].toExternalForm(); 
	}

	java.lang.String redirect_to = this.props.getProperty("del.redirect");

	response.setContentType("text/plain");
	response.setCharacterEncoding("UTF-8");
	response.sendRedirect(redirect_to);
	java.io.PrintWriter out   = response.getWriter();
	out.println(text);

    }
}
