#!/usr/bin/perl -w

use strict;
use LWP::UserAgent;
use Getopt::Long;

my $scheme = "http://";
my $suri   = "dcm-udv-01.kb.dk:8080/exist/rest";
my $turi   = "dcm-udv-01.kb.dk:8080/exist/rest";
my $source = "/db/public";
my $target = "/db/cnw/data";
my $since  = "2014-01-16T15:19:55";
my $before = "2099-12-31T24:00:00";
my $files  = "http://dcm-udv-01.kb.dk/storage/document-names.xq?" .
    join ("&",
	  (
	   "c=CNW",
	   "db=$source",
	   "since=$since",
	   "before=$before"
	  )
    );

my $ua = LWP::UserAgent->new;
$ua->agent("crud-client/0.1 ");
#$ua->credentials($host_port, "exist" , $user, $password );

my $req = new HTTP::Request();
$req->uri($files);
$req->method("GET");

# $req->header( "Content-Type" => $suffixes{$suffix} );

# Pass request to the user agent and get a response back

my $res = $ua->request($req);

## Check the outcome of the response

if ($res->is_success) {
    print STDERR "Success getting $files list " . $res->status_line . "\n";
    my @filelist = split("\n",$res->content());

    foreach my $line (@filelist) {
	my ($file,$date) = split /\s+/,$line;
	my $req = new HTTP::Request();
	my $url = $scheme . $suri . $source .'/' .  $file;
	$req->method("HEAD");
	$req->uri($url);
	my $res = $ua->request($req);
	if ($res->is_success) {
	    print STDERR "$url :" . $res->status_line . "\n";
	    # print STDERR $res->headers()->as_string();
	    # print STDERR $res->header( "Last-Modified" );
	} else {
	    print STDERR "$file :" . $res->status_line . " bah :( \n";
	}
    }
} else {
	die "mirror.pl has problems with $files URI";
}

