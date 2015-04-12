use strict;
use warnings;
use HTTP::Tiny;
use Data::Dumper;
use JSON;

use Test::More tests => 3;
BEGIN { use_ok('Spline::Tool::Tokenizer2') };

my $host = $ENV{SPLINE_HOST} || 'localhost';
my $port = $ENV{SPLINE_PORT} || 8080;

my %params = ();
$params{api_token} = 'KajMZtKtTt';
$params{text} = 'Eu sou o Nuno.';

my $got = HTTP::Tiny->new->post_form("http://".$host.":".$port."/tokenizer2", \%params);
my $result = decode_json($got->{content});

my @final = ('Eu', 'sou', 'o', 'Nuno', '.'); 
ok($result->[0] eq $final[0], "Simple input-output test");

ok((scalar @{$result}) == (scalar @final), "Test the result length");

