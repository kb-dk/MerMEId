#!/usr/bin/perl -w

use strict;
use LWP::UserAgent;
use Getopt::Long;
use DateTime;

my $scheme = "http://";
my $suri   = "dcm-udv-01.kb.dk:8080/exist/rest";
my $turi   = "dcm-udv-01.kb.dk:8080/exist/rest";
my $source = "/db/public";
my $target = "/db/cnw/data";
my $edition= "hartw";
my $since  = "2000-01-01T00:00:01";
my $before = "2099-12-31T24:00:00";
my $files  = "http://dcm-udv-01.kb.dk/storage/document-names.xq?" .
    join ("&",
	  (
	   "c=$edition",
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

    my $latest_modification = &parse_date_time("2000-01-01T00:00:01");
    foreach my $line (@filelist) {
	my ($file,$date) = split /\s+/,$line;
	my $docdate = &parse_date_time($date);
	if(DateTime->compare( $latest_modification, $docdate ) < 0 ) {
	    $latest_modification = $docdate ;
	}
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
    print STDERR "$latest_modification\n";
} else {
	die "mirror.pl has problems with $files URI";
}



sub parse_date_time {
    my $dtf = shift;

    $dtf =~ m/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d).*$/;

    return DateTime->new(
	year       => $1,
	month      => $2,
	day        => $3,
	hour       => $4,
	minute     => $5,
	second     => $6,
	time_zone  => 'CET');
}
