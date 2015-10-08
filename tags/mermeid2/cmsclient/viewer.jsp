<%@page contentType="text/xml;charset=UTF-8"%>
<%@page import="org.opencms.jsp.*" %>

<%

 /*
  * Delivers a data stored in an xml file
  * Author: Sigfrid Lundberg (slu@kb.dk)
  * $Id$
  * Last modified $Date$ by $Author$
  *
  */

String sheet = "pn-artikler_server_side.xsl";
if(request.getParameter("sheet") != null) {
    sheet = request.getParameter("sheet") + "";
}

String id    = "";
if(request.getParameter("id") != null) {
    id = request.getParameter("id") + "";
}

String sort  = "";
if(request.getParameter("sort") != null) {
    sort = request.getParameter("sort") + "";
}

String xml_file   = "PN-IH.xml";
if(request.getParameter("file") != null) {
    xml_file = request.getParameter("file") + "";
}

String serverName = request.getServerName();
int portNumber    = request.getServerPort();
String host_port  = serverName + ":" + portNumber;
String xsl_dir    = "http://" + host_port + "/da/kb/nb/mta/dcm/udgivelser/norgard/";
String xsl_name   = xsl_dir + sheet; 
String xml_dir    = "http://" + host_port + "/da/kb/nb/mta/dcm/udgivelser/norgard/";
String xml_name   = xml_dir + xml_file;

org.w3c.dom.Document source_dom = null;
javax.xml.parsers.DocumentBuilder dBuilder = null;

javax.xml.parsers.DocumentBuilderFactory dfactory  =
    javax.xml.parsers.DocumentBuilderFactory.newInstance();

javax.xml.transform.TransformerFactory trans_fact  = 
    javax.xml.transform.TransformerFactory.newInstance();

java.net.URL           uri        = new java.net.URL(xml_name);
java.net.URLConnection connection = uri.openConnection();
java.io.InputStream    in         = connection.getInputStream();

try {
    dfactory.setNamespaceAware(true);
    dBuilder = dfactory.newDocumentBuilder();
    source_dom = dBuilder.parse(in);
} catch (javax.xml.parsers.ParserConfigurationException parserPrblm) {
    System.out.println(parserPrblm.getMessage());
} catch (org.xml.sax.SAXException xmlPrblm) {
    System.out.println(xmlPrblm.getMessage());
}

javax.xml.transform.dom.DOMSource source = 
    new javax.xml.transform.dom.DOMSource(source_dom);

javax.xml.transform.dom.DOMResult result = 
    new javax.xml.transform.dom.DOMResult();

javax.xml.transform.stream.StreamSource xsl_source =
    new javax.xml.transform.stream.StreamSource(xsl_name);

String result_string = "";
try {
    javax.xml.transform.Transformer transformer = 
	trans_fact.newTransformer(xsl_source);
    if(xsl_source == null) {
	System.out.println("xsl_source null");
    }
    if(transformer == null) {
	System.out.println("transformer  null");
    }
    if(sort.length() > 0 ) {
	transformer.setParameter("sort", sort);
    }
    if(id.length() > 0 ) {
	transformer.setParameter("id"  , id);
    }
    transformer.setParameter("file"  , xml_file);

    transformer.transform(source, result); 
    if(result != null) {
	result_string = serialize( (org.w3c.dom.Document)result.getNode() );
    }

} catch(javax.xml.transform.TransformerConfigurationException tfCfgPrblm) {
    System.out.println(tfCfgPrblm.getMessage());
} catch(javax.xml.transform.TransformerException tfPrblm) {
    System.out.println(tfPrblm.getMessage());
}



%>


<div class="article">
<div class="articleBody">
<%
out.println(result_string);
%>
</div>
</div>

<%!

String serialize(org.w3c.dom.Document doc) {

      try {
	  org.w3c.dom.bootstrap.DOMImplementationRegistry registry =
	      org.w3c.dom.bootstrap.DOMImplementationRegistry.newInstance();

	  org.w3c.dom.ls.DOMImplementationLS impl =
	      (org.w3c.dom.ls.DOMImplementationLS) registry.getDOMImplementation("LS");

	  org.w3c.dom.ls.LSSerializer serializer = impl.createLSSerializer();
	  return serializer.writeToString(doc);

      } catch (java.lang.ClassNotFoundException classNotFound) {
	  System.out.println(classNotFound.getMessage());
      } catch (java.lang.InstantiationException instantiationPrblm) {
	  System.out.println(instantiationPrblm.getMessage());
      } catch (java.lang.IllegalAccessException accessPrblm) {
	  System.out.println(accessPrblm.getMessage());
      }
      return "";
  }


%>
