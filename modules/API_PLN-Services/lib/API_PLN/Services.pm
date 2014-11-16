package API_PLN::Services;

use 5.018002;
use strict;
use warnings;
use HTTP::Tiny;
use Data::Dumper;
use URI::Escape;
use JSON;
use Sub::Install;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(
	&import
);
our $VERSION = '0.01';

sub import {
	my $url = "http://localhost:8080/info";

	my $response = HTTP::Tiny->new->get($url);
	if (! $response->{success}) {
		die "$response->{status}: $response->{reason}";
	}

	my $data_structure = decode_json($response->{content});

	for my $method (@$data_structure) {
		Sub::Install::install_sub({
			code => sub {
				my %params = @_;
				print Dumper(\%params);
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
