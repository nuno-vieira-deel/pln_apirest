package Spline::Services;

use 5.018002;
use strict;
use warnings;
use HTTP::Tiny;
use Data::Dumper;
use URI::Escape;
use JSON;
use Sub::Install;

sub import {
	my $url = "http://localhost:8080/info";

	my $response = HTTP::Tiny->new->get($url);
	die if (!$response->{success});

	my $data_structure = decode_json($response->{content});

	for my $method (@$data_structure) {
		Sub::Install::install_sub({
			code => sub {
				my %params = @_;
				## tv seja preciso converter alguns parametros do %param para JSON, etc.
				my $res = HTTP::Tiny->new->post_form("http://localhost:8080/".$method, \%params);
				die "$res->{status}: $res->{reason}" unless $response->{success};
				return decode_json($res->{content});
			},
			into => "main", ## need to test
			as => $method,
		});
	}
}

1;
__END__
