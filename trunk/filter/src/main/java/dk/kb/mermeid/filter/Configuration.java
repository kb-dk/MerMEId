package dk.kb.mermeid.filter;

public class Configuration {

     private static org.apache.log4j.Logger logger = 
	 org.apache.log4j.Logger.getLogger(Configuration.class);

    private java.util.Properties props = null;

    private static Configuration ourInstance = new Configuration();

    public static Configuration getInstance() {
        return ourInstance;
    }

    private Configuration () {
        String propFile = "/http_filter.xml";
        this.setConstants(propFile);
    }

    public void setConstants(String propFile) {
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

    public java.util.Properties getConstants() {
        return this.props;
    }

    public java.util.Enumeration<String> propertyNames() {
        return (java.util.Enumeration<String>)this.props.propertyNames();
    }

    java.util.Map<String,Object> propertyMap(java.lang.String keyBase) {
	java.util.HashMap<String,Object> map = new java.util.HashMap();
	
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
