#!/usr/bin/perl

use strict;

use LWP::UserAgent;
use JSON;
use Data::Dumper;

# initialize session and stuff

my $url = "http://www.cubetutor.com/search/1";

my $ua = LWP::UserAgent->new;
my $request = HTTP::Request->new(GET => $url);
my $response = $ua->request($request);

die "Error ".$response->code if !$response->is_success;

#print $response->decoded_content;

my $content = $response->decoded_content;

my $action; 
my $t_ac;
my $t_formdata;
my $jsessionid;
foreach ( split(/\n/, $content) ) {
	# get the search form
	$_ =~ /(<form[^>]*action="\/search.*<\/form>)/ || next;
	my $form = $1;
	$form =~ s/<form class="cardForm".*//;
	#print $form;

	# extract params
	$form =~ /action="([^"]*)".*value="([^"]*)" name="t:ac".*value="([^"]*)" name="t:formdata"/;
	($action, $t_ac, $t_formdata) = ($1, $2, $3);
	($action, $jsessionid) = split(/;jsessionid=/, $action);
	$t_formdata =~ s/=/%3D/g;
	$t_formdata =~ s/:/%3A/g;
	$t_formdata =~ s/\//%2F/g;
	$t_formdata =~ s/\+/%2B/g;
}

# go through each page of search results

$url = "http://www.cubetutor.com$action";

# limit our crawling to the first 20 pages (100 results)
for (my $i=0; $i < 20; $i++) {

	$request = HTTP::Request->new(POST => $url);
	#$request->header('Host' => 'www.cubetutor.com');
	#$request->header('User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64; rv:41.0) Gecko/20100101 Firefox/41.0');
	#$request->header('Accept' => '*/*');
	#$request->header('Accept-Language' => 'en-US,en;q=0.5');
	#$request->header('Accept-Encoding' => 'gzip, deflate');
	#$request->header('DNT' => '1');
	$request->header('Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8');
	$request->header('X-Requested-With' => 'XMLHttpRequest');
	#$request->header('Pragma' => 'no-cache');
	#$request->header('Cache-Control' => 'no-cache');
	#$request->header('Referer' => 'http://www.cubetutor.com/search/1');
	#$request->header('Content-Length' => '548');
	$request->header('Cookie' => "JSESSIONID=$jsessionid; userStatus=FREE_USER");
	#$request->header('Connection' => 'keep-alive');
	$request->content("t%3Aac=$t_ac&t%3Aformdata=$t_formdata&user=&cubeName=multiplayer&minCubeSize=&maxCubeSize=&minDraftCount=&t%3Azoneid=indexGridZone");
	
	$response = $ua->request($request);
	
	die "Error ".$response->code if !$response->is_success;
	
	my $jcontent = $response->decoded_content;
	my $json = decode_json $jcontent;
	
	$content = $json->{'content'};
	$content =~ s/\n//g;
	#print Dumper $content;
	
	while ($content =~ /<td class='id'>(\d*).*<span>([^<]*).*a href='\/cubeblog\/\1'>([^<]*)/g) {
	
		my ($id, $user, $cubename) = ($1, $2, $3);
		print "$id $user $cubename\n";
	}
	
	# get more search results
	$url = "http://www.cubetutor.com/search.loadmore?t:ac=1";

}

