package dk.kb.mermeid.filter;

/**
 * This servlet implements a filter like HTTP proxy
 * @author Sigfrid Lundberg (slu@kb.dk)
 * @version $Revision$
 * Last modified $Date$
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
	    = Configuration.getInstance().propertyMap("create");

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
