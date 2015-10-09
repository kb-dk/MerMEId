package dk.kb.mermeid.filter;

/**
 * <p>A singleton used as a storage and retrieval of configuration
 * parameters.</p>
 */
public class Configuration {

     private static org.apache.log4j.Logger logger = 
	 org.apache.log4j.Logger.getLogger(Configuration.class);

    private java.util.Properties props = null;

    /*
     * We instantiate ourselves as a static Configuration
     */
    private static Configuration ourInstance = new Configuration();

    /**
     * <p>We return ourselves as the instance</p>
     * @return a Configuration instance
     */
    public static Configuration getInstance() {
        return ourInstance;
    }

    /**
     * <p>Constructor. Reads a java property file called http_filter.xml</p>
     * @see java.util.Properties;
     */
    private Configuration () {
        String propFile = "/http_filter.xml";
        this.setConstants(propFile);
    }

    /**
     * <p>Read the configuration</p>
     * @param propFile the name of the configuration file
     */
    private void setConstants(String propFile) {
        this.props = new java.util.Properties();
        try {
	    java.io.InputStream in = this.getClass().getResourceAsStream(propFile);
            props.loadFromXML(in);
        } catch (java.io.FileNotFoundException fileNotFound) {
            logger.error(
			 String.format("The file '%s' was not found",
				       propFile),
			 fileNotFound);
        } catch (java.io.IOException ioException) {
            logger.error(String.format("An exception occurred while reading " + 
				       "from the file '%s' ", propFile), ioException);
        }
    }

    /**
     * @return cparameters as java properties 
     */
    public java.util.Properties getConstants() {
        return this.props;
    }

    /**
     * @return the property names as an Enumeration of String
     */
    public java.util.Enumeration<String> propertyNames() {
        return (java.util.Enumeration<String>)this.props.propertyNames();
    }

    /**
     * @return parameters as a Map rather than properties
     */
    public java.util.Map<String,Object> propertyMap(java.lang.String keyBase) {
	java.util.HashMap<String,Object> map = new java.util.HashMap<String,Object>();
	
	java.util.Enumeration<String> enumeration = this.propertyNames();

	while(enumeration.hasMoreElements()) {
	    String element = enumeration.nextElement();
	    if(element.startsWith(keyBase + ".") ) {
		logger.debug("found element " + element);
		java.lang.String newKey =
		    element.substring(keyBase.length()+1,element.length());
		java.lang.String value  = this.props.getProperty(element);

		logger.debug(element + 
			     " gives new key " + 
			     newKey + " with value " + value);

		map.put(newKey,value);
	    }
	}
	return map;
    }

}
