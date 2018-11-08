package dk.kb.mermeid.filter;

/**
 * <p>This servlet accepts <strong>GET</strong> requests on URIs matching the
 * /new/* pattern.  It will as a response generate a new unique URI and
 * redirect a client to it.</p>
 * @author Sigfrid Lundberg (slu@kb.dk)
 * @version $Revision: 390 $
 * Last modified $Date: 2013-01-15 15:45:59 +0100 (Tue, 15 Jan 2013) $
 */
public class NewFileServlet extends javax.servlet.http.HttpServlet {

    private javax.servlet.ServletConfig srvConf   = null;
    private java.lang.Long              start     = null;
    private java.util.Properties        props     = null;
    private FilterUtilityMethods        utilities = new  FilterUtilityMethods();
    private org.apache.log4j.Logger     logger    = 
	org.apache.log4j.Logger.getLogger(NewFileServlet.class.getPackage().getName());

    public NewFileServlet () {
	this.props = Configuration.getInstance().getConstants();
    }


    public void doGet(javax.servlet.http.HttpServletRequest request,
		      javax.servlet.http.HttpServletResponse response) 
	throws javax.servlet.ServletException, java.io.IOException 
    {        

	String requestUri = utilities.uriConstructor(request,response);

	String pattern = this.props.getProperty("create." + utilities.getBase());

	com.damnhandy.uri.template.impl.RFC6570UriTemplate template = 
	    new com.damnhandy.uri.template.impl.RFC6570UriTemplate(pattern);

	String file = IdGenerator.getInstance().getId() + ".xml";

	java.util.Map<String,Object> parameters 
	    = Configuration.getInstance().propertyMap("create." + utilities.getBase());

	parameters.put("doc",file);


	java.lang.String redirect_to = template.expand(parameters);
	java.lang.String text        = 
	    "You were about to be redirected to " +
	    redirect_to;

	response.setContentType("text/plain");
	response.setCharacterEncoding("UTF-8");
	response.sendRedirect(redirect_to);
	java.io.PrintWriter out   = response.getWriter();
	out.println(text);
	logger.debug(text);

    }
}
