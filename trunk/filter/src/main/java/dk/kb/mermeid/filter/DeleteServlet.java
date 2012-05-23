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

	response.setContentType("text/xml");
	request.setCharacterEncoding("UTF-8");

	java.lang.Long start = System.currentTimeMillis();

	org.apache.commons.httpclient.HttpClient httpClient = 
	    new org.apache.commons.httpclient.HttpClient();

	httpClient.getHttpConnectionManager().getParams().setConnectionTimeout(5000);

	httpClient.getParams().setParameter("http.protocol.single-cookie-header", true);
	httpClient.getParams().setCookiePolicy(
	       org.apache.commons.httpclient.cookie.CookiePolicy.BROWSER_COMPATIBILITY );

	String targetUri = this.utilities.uriConstructor(request,response);


	logger.debug("Sending request to URI: " + targetUri); 

	//create a method object
	org.apache.commons.httpclient.methods.DeleteMethod put_method =
	    new org.apache.commons.httpclient.methods.DeleteMethod();

    }
}
