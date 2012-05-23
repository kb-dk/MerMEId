#!/usr/bin/perl -w

#
# A script that can be used loading and deleting files in an exist database.
# $Revision: 1.4 $ last modified $Date: 2011/08/29 12:42:29 $ by $Author: slu $
#

use strict;
use LWP::UserAgent;
use Getopt::Long;

my $scheme    = "http://";
my $host_port = "localhost:8080";
my $context   = "/exist/rest/db/";
my $target    = "";
my $user      = "";
my $password  = "";
my $load      = '';
my $delete    = '';
my $get       = '';
my $suffix    = '';

# http://kb-cop.kb.dk:8080/exist/index.xml
# admin password florsocker

my $result = GetOptions (
    "load=s"        => \$load,
    "get=s"         => \$get,
    "delete=s"      => \$delete,
    "target=s"      => \$target,
    "context=s"     => \$context,
    "user=s"        => \$user,
    "suffix=s"      => \$suffix,
    "host-port=s"   => \$host_port,
    "password=s"    => \$password);

my $source = "";
if($load) {
    $source = $load;
} elsif($delete) {
    $source = $delete;
} elsif($get) {
    $source = $get;
} else {
    &usage();
}

my %suffixes = ('xml' => 'text/xml',
		'xq'  => 'application/xquery');

exit() unless $source;

my $files  = "/usr/bin/find $source -name '*$suffix' -print |";

if(open FIND,$files) {
    
    my $ua = LWP::UserAgent->new;
    $ua->agent("crud-client/0.1 ");
    $ua->credentials($host_port, "exist" , $user, $password );

    while(my $file = <FIND>) {

	chomp $file;
	print STDERR "$file\n";

	if (open CONTENT,"<$file") {
	    my $content = "";
	    while(my $line = <CONTENT>) {
		$content .= $line;
	    }

	    $file =~ s/$source/$target/;
	    my $req_uri = $scheme . $host_port . $context . $file;
	    print STDERR $req_uri . "\n";

# Create a request

	    my $req = new HTTP::Request();
	    $req->uri($req_uri);
	    if($load) {
		$req->method("PUT");
		$req->content($content);
	    } elsif($delete) {
		$req->method("DELETE");
	    } else {
		$req->method("GET");
	    }
	    $req->header( "Contnent-Type" => $suffixes{$suffix} );

# Pass request to the user agent and get a response back
	    my $res = $ua->request($req);

## Check the outcome of the response
	    if ($res->is_success) {
		print STDERR "Success ", $res->status_line, "\n";
	    } else {
		print STDERR "Failure ", $res->status_line, "\n";
	    }
	    close CONTENT;
	}
    }
}

sub usage {

    print <<"END";
Correct usage:
$0 <options>
where options are
   --load <directory> 
        from where to read files for loading
   --get <directory>
        where to write retrieved files
   --delete <directory with a backup>
        the files in that are found in the directory will be deleted from the
        database if there exist files with the same name

    --suffix <suffix> 
        file suffix to look for in directory. for example xml

    --target <target name>
        Basically database name. Default is $target

    --context <context>
        Root for the rest services. Default is $context

    --user <user name>
    --password <password of user>
    --host-port <host and port for server>
        Default is localhost:8080

For example

$0 \
      --host-port kb-cop.kb.dk:8080  \\
      --suffix xml \\
      --load ../../mei_editor_test/data/ \\
      --context $context \\
      --target $target

will load the xml-files in directory ../../mei_editor_test/data/ into a
database with base URI

http://kb-cop.kb.dk:8080/exist/rest/db/dcm-catalog/

END

}

#
# $Log: load_exist.pl,v $
# Revision 1.4  2011/08/29 12:42:29  slu
# OK
#
# Revision 1.3  2011/05/12 07:54:23  slu
# added RCS macron
#
#

#./load_exist.pl --host-port kb-cop.kb.dk:8080 --suffix xml --load ../../mei_editor_test/data/  --context /exist/rest/db/ --target dcm-catalog/

