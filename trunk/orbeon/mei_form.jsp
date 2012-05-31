<%@page contentType="text/html;charset=UTF-8"%>
<%@page import="java.io.*"%>
<%@page import="org.apache.log4j.*"%>
<%
response.setContentType("text/xml");
request.setCharacterEncoding("UTF-8");

java.lang.Long start = System.currentTimeMillis();
Logger logger = Logger.getLogger("mei_form.jsp");

org.apache.commons.httpclient.HttpClient httpClient = 
    new org.apache.commons.httpclient.HttpClient();

String pathInfo    = request.getPathInfo(); 
String uri         = request.getParameter("uri");
String queryString = request.getQueryString();
String newRequest  = queryString;
httpClient.getHttpConnectionManager().getParams().setConnectionTimeout(5000);

//if(logger.isInfoEnabled()){ 
//System.out.println("Sending request: " + newRequest); 
//}

//create a method object
org.apache.commons.httpclient.HttpMethod method = 
    new org.apache.commons.httpclient.methods.GetMethod(uri);

method.setFollowRedirects(true);
httpClient.executeMethod(method);

org.apache.commons.httpclient.Header[] responseHeaders = method.getResponseHeaders();

int status = method.getStatusLine().getStatusCode();
//if(logger.isInfoEnabled()) {
        System.out.println("response status:\t" + 
		status + 
	" (" + method.getStatusLine().toString()  + ")"); 
//}

for(int i=0;i<responseHeaders.length;i++) {
    if(logger.isInfoEnabled()) {
	logger.info("response:\t" + responseHeaders[i].toExternalForm()); 
    }
}
        
java.io.InputStream in  = method.getResponseBodyAsStream();
java.io.PrintWriter responseOut = response.getWriter();
int length;
while((length = in.read()) != -1){
    responseOut.write(length);
}

java.lang.Long completed = System.currentTimeMillis() - start;
      
if(logger.isInfoEnabled()){ 
    logger.info(".. work done in " + completed + " ms"); 
}

responseOut.flush();
responseOut.close();
in.close();



%>
