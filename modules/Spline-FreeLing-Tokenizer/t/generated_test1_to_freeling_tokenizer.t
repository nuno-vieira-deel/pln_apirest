use strict;
use warnings;
use HTTP::Tiny;
use Data::Dumper;
use JSON;

use Test::More tests => 3;
BEGIN { use_ok('Spline::FreeLing::Tokenizer') };

my $host = $ENV{SPLINE_HOST} || 'localhost';
my $port = $ENV{SPLINE_PORT} || 8080;

my %params = ();
$params{api_token} = 'MAIlGopQUt';
$params{text} = 'I will be tokenized.';

my $got = HTTP::Tiny->new->post_form("http://".$host.":".$port."/tokenizer", \%params);
my $result = decode_json($got->{content});

ok($result->[0] eq 'I', "Test the first word");

ok((scalar @{$result}) == 5, "Test the result length");

