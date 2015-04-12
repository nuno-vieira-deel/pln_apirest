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
$params{api_token} = 'KajMZtKtTt';
$params{text} = 'Eu sou o Nuno.';

my $got2 = HTTP::Tiny->new->post_form("http://".$host.":".$port."/tokenizer", \%params);
my $got = decode_json($got2->{content});
my @res = ('Eu', 'sou', 'o', 'Nuno', '.');

ok($got->[0] eq $res[0], "Simple input-output test");
ok((scalar @{$got}) == (scalar @res), "Test the result length");