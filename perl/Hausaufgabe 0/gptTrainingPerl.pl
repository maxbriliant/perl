use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Cookies;

my $url = '	';
my $cookie_jar = HTTP::Cookies->new(file => "cookies.txt", autosave => 1, ignore_discard => 1);
my $ua = LWP::UserAgent->new;

$ua->agent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');
$ua->cookie_jar($cookie_jar);
$ua->default_header('Referer' => 'https://www.ecosia.org/');
$ua->default_header('Accept-Language' => 'en-US,en;q=0.5');

my $response = $ua->get($url);

if ($response->is_success) {
	my $content = $response->decoded_content;

	print $content;
	} else {
		die $response->status_line;
	}

