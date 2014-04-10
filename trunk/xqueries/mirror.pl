#!/usr/bin/perl -w

use strict;
use LWP::UserAgent;
use Getopt::Long;
use DateTime;


my $scheme    = "http://";
my $source_host_port = "dcm-udv-01.kb.dk:8080";
my $target_host_port = "dcm-udv-01.kb.dk:8080";
my $user      = "admin";
my $password  = "flormelis";
my $suri      = $scheme . $source_host_port . "/exist/rest/db";
my $turi      = $scheme . $target_host_port . "/exist/rest/db";
my $source    = "/public";
my $target    = "/cnw/data";
my $edition   = "cnw";
my $since     = "2000-01-01T00:00:01";
my $before    = "2099-12-31T24:00:00";

#####
#
# Collecting data on source files
#

my $source_files     = $suri . "/document-info.xq?" .
    join ("&",
	  (
	   "c=$edition",
	   "db=$source",
	   "since=$since",
	   "before=$before"
	  )
    );

my $target_files     = $turi . "/document-info.xq?" .
    join ("&",
	  (
	   "c=$edition",
	   "db=$target"
	  )
    );

my %sources = &get_data($source_files); 
my %targets = &get_data($target_files); 
my @filelist = keys(%sources);

my $latest_modification = &parse_date_time("2000-01-01T00:00:01");

print "about to process $#filelist files\n";

foreach my $file (@filelist) {

    print STDERR "doing $file \n";
    
    my $docdate = &parse_date_time($sources{$file});

    if(DateTime->compare( $latest_modification, $docdate ) < 0 ) {
	$latest_modification = $docdate ;
    }

    my $req = new HTTP::Request();
    my $target_url = $turi . $target .'/' .  $file;
    my $source_url = $suri . $source .'/' .  $file;

    &copy_file($source_url,$target_url);

}

@filelist = keys(%targets);
foreach my $file (@filelist) {
    if($sources{$file}) {
#	print STDERR "The file $file is in the source database\n";
    } else {
	my $target_url = $turi . $target .'/' .  $file;
	print STDERR "The file $file is in the target database only should be removed\n";
	&delete_file($target_url);
    }
    
}
    
sub get_data {
    my $files = shift ;

    my %data = ();

    my $ua = LWP::UserAgent->new;
    $ua->agent("crud-client/0.1 ");
    $ua->credentials($target_host_port, "exist" , $user, $password );

    my $req = new HTTP::Request();
    $req->uri($files);
    $req->method("GET");
    my $res = $ua->request($req);

    if ($res->is_success) {
	print STDERR "Success getting $files list " . $res->status_line . "\n";
	my @fileitems = split("\n",$res->content());


	print STDERR "About to parse $#fileitems files\n";
	
	foreach my $line (@fileitems) {
	    my ($file,$date) = split /\s+/,$line;
	    $data{$file} = $date;
	}

    }

    return %data;
}



sub parse_date_time {
    my $dtf = shift;

    $dtf =~ m/^(\d\d\d\d)-?(\d\d)-?(\d\d)T(\d\d):?(\d\d):?(\d\d).*$/;

    return DateTime->new(
	year       => $1,
	month      => $2,
	day        => $3,
	hour       => $4,
	minute     => $5,
	second     => $6,
	time_zone  => 'CET');
}

sub delete_file {
    my $url = shift;

    print STDERR "delete_file called\n";
    my $ua = LWP::UserAgent->new;
    $ua->credentials($target_host_port, "exist" , $user, $password );
    my $delreq = new HTTP::Request();
    $delreq->method("DELETE");
    $delreq->uri($url);
    my $delres = $ua->request($delreq);
    if($delres->is_success) {
	print STDERR "Successfully removed file $url\n";
    }
}

sub copy_file {
    my $source_url = shift;
    my $target_url = shift;

    print STDERR "copy_file called\n";
    my $ua = LWP::UserAgent->new;
    my $getreq = new HTTP::Request();
    $getreq->method("GET");
    $getreq->uri($source_url);
    my $getres = $ua->request($getreq);
    if($getres->is_success) {
	$ua->credentials($target_host_port, "exist" , $user, $password );
	print STDERR "got content from $source_url " . $getres->code . "\n";
	my $content = $getres->content();
	my $putreq = new HTTP::Request();
	$putreq->method("PUT");
	$putreq->content($content);
	$putreq->uri($target_url);
	my $putres = $ua->request($putreq);
	if($putres->is_success) {
	    print STDERR "managed to put content to $target_url " . 
		$putres->code . "\n";	
	} else {
	    print STDERR "failed to put content to $target_url " . 
		$putres->code . "\n";	
	}
    } else {
	print STDERR "failed to get content from $source_url " 
	    . $getres->code . "\n";
    }
}
