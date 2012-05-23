<%@page contentType="text/html;charset=UTF-8"%>
<%@page import="java.io.*"%>
<%@page import="org.apache.log4j.*"%>
<%
response.setContentType("text/xml");
request.setCharacterEncoding("UTF-8");

java.lang.Long start = System.currentTimeMillis();

org.apache.commons.httpclient.HttpClient httpClient = 
    new org.apache.commons.httpclient.HttpClient();

httpClient.getHttpConnectionManager().getParams().setConnectionTimeout(5000);

httpClient.getParams().setParameter("http.protocol.single-cookie-header", true);
httpClient.getParams().setCookiePolicy(
	   org.apache.commons.httpclient.cookie.CookiePolicy.BROWSER_COMPATIBILITY );

logger.debug("Sending request to URI: " + targetUri); 

//create a method object
org.apache.commons.httpclient.methods.DeleteMethod put_method =
    new org.apache.commons.httpclient.methods.DeleteMethod();



/*

#!/usr/bin/perl -w

use strict;
use LWP::UserAgent;
use lib 'lib';
use cgirequest;
use EditorConfig();

#
# Author: Sigfrid Lundberg (slu@kb.dk)
# $Revision: 64 $ last modified $Date: 2011-09-16 13:21:28 +0200 (Fri, 16 Sep 2011) $ by $Author: slu $
#

my $conf     = new EditorConfig("");
my $user     = $conf->parameter('exist.user');
my $password = $conf->parameter('exist.password');

my $query  = new cgirequest;
my $file     = $query->param('file');

print STDERR "my file is $file\n";

my $ua       = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");
my $host_port = $ENV{'HTTP_HOST'} . ':' . $ENV{'SERVER_PORT'};

# Pass request to the user agent and get a response back
$file =~ m/(http:\/\/)(.+):(\d+)/;
my $exist_file = $file;
$exist_file =~ s|^.*?dcm/|http://localhost:8080/exist/rest/db/dcm/|;

# Create a request
#my $req = HTTP::Request->new(DELETE => $file);
my $req = HTTP::Request->new(DELETE => $exist_file);

$ua->credentials('localhost:8080', "exist", $user, $password);
my $res = $ua->request($req);

print "Location: http://" . $ENV{'HTTP_HOST'} . ':' . $ENV{'SERVER_PORT'} . "/storage/list_files.xq\n";
print "Content-Type: text/plain\n\n";
print STDERR "credentials = $user , $password\n";
print STDERR "host port   = $host_port\n";
print STDERR "file        = $file\n";
print STDERR "exist file  = $exist_file\n";

# Check the outcome of the response
if ($res->is_success) {
    print STDERR "Success ",  $res->status_line, "\n";
}
else {
    print STDERR "Failure ",  $res->status_line, "\n";
}

print "Status line: ", $res->status_line, "\n";
print $res->content();

*/
