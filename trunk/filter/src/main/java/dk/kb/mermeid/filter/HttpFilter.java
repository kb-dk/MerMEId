package dk.kb.mermeid.filter;

/**
 * This servlet implements a filter like HTTP proxy
 * @author Sigfrid Lundberg (slu@kb.dk)
 * @version $Revision$
 * Last modified $Date$
 */
public class HttpFilter extends javax.servlet.http.HttpServlet {


    private javax.servlet.ServletConfig srvConf = null;
    private java.lang.Long                start = null;
    private java.util.Properties          props = null;
    private FilterUtilityMethods      utilities = new  FilterUtilityMethods();
    private org.apache.log4j.Logger logger = 
	org.apache.log4j.Logger.getLogger(
					  HttpFilter.class.getPackage().getName());


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
	this.utilities.setStart(this.start);
	logger.debug("Starting GET transaction ");
	this.utilities.recieveAndFilterData(request,response);
    }

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
