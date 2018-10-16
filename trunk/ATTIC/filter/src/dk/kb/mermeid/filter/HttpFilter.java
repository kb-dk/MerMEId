package dk.kb.mermeid.filter;

/**
 * <p>This servlet implements a filtering HTTP proxy. It will accept GET, POST
 * and PUT requests from remote client. It will handle them as follows:</p>
 *
 * <p><strong>GET</strong> The sub-request for requested document will be sent
 * to another server, the CRUD server. When retrieved this document will be
 * transformed using a XSLT <q>get filter</q> and is than deliverefd to the
 * client.</p>
 *
 * <p><strong>POST</strong> The filter accepts content and
 * transforms it using the <q>put filter</q>. It then generates a unique file
 * name and PUTs the content to that URI on the CRUD server.</p> 
 *
 * <p>Finally, <strong>PUT</strong>. It is assumed that the URI the client is
 * using reflects the documents URI on the CRUD server. The document is stored
 * there after passing the <q>put filter</q>.</p>
 *
 * @author Sigfrid Lundberg (slu@kb.dk)
 * @version $Revision: 392 $
 * Last modified $Date: 2013-01-16 14:39:17 +0100 (Wed, 16 Jan 2013) $
 */
public class HttpFilter extends javax.servlet.http.HttpServlet {


    private javax.servlet.ServletConfig srvConf = null;
    private java.lang.Long                start = null;
    private java.util.Properties          props = null;
    private FilterUtilityMethods      utilities = new  FilterUtilityMethods();
    private org.apache.log4j.Logger logger = 
	org.apache.log4j.Logger.getLogger(
					  HttpFilter.class.getPackage().getName());


    /**
     * <p>Class Constructor. Does really nothing except reading the
     * Configuration</p>
     * @see Configuration
     */
    public HttpFilter() {
	this.props = Configuration.getInstance().getConstants();
    }

    /**
     * <p>Called once by the servlet container after the class has been
     * instantiated.</p>
     * @param srvConf
     */
    public void init(javax.servlet.ServletConfig srvConf) 
	throws javax.servlet.ServletException
    {
	this.srvConf = srvConf;
    }

    /**
     * <p>This one is used by the servlet container. God and servlet
     * container authors knows what it means</p>
     * @return the servlet configuation
     * @see javax.servlet.ServletConfig
     */
    public javax.servlet.ServletConfig getServletConfig() {
	return this.srvConf;
    }

    /**
     * <p>Called by the servlet container for each GET request</p>
     * @param request an HttpServletRequest object that contains the request the client has made of the servlet
     * @param response an HttpServletResponse object that contains the response the servlet sends to the client 
     */
    public void doGet(javax.servlet.http.HttpServletRequest request,
		      javax.servlet.http.HttpServletResponse response) 
	throws javax.servlet.ServletException, java.io.IOException 
    {        
	this.start = System.currentTimeMillis();
	this.utilities.setStart(this.start);
	logger.debug("Starting GET transaction ");
	this.utilities.recieveAndFilterData(request,response);
    }

    /**
     * <p>Called by the servlet container for each GET request</p>
     * @param request an HttpServletRequest object that contains the request the client has made of the servlet
     * @param response an HttpServletResponse object that contains the response the servlet sends to the client 
     */
    public void doPost(javax.servlet.http.HttpServletRequest request,
		       javax.servlet.http.HttpServletResponse response) 
	throws javax.servlet.ServletException, java.io.IOException
    {        
	this.start = System.currentTimeMillis();
	this.utilities.setStart(this.start);
	logger.debug("Starting POST transaction ");
	this.utilities.filterAndSubmitData(request,response);
    }

    public void doPut(javax.servlet.http.HttpServletRequest request,
		      javax.servlet.http.HttpServletResponse response) 
	throws javax.servlet.ServletException, java.io.IOException 
    {        
	this.start = System.currentTimeMillis();
	this.utilities.setStart(this.start);
	logger.debug("Starting PUT transaction ");
	this.utilities.filterAndSubmitData(request,response);
    }
}
