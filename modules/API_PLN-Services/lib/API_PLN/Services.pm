package API_PLN::Services;

use 5.018002;
use strict;
use warnings;
use HTTP::Tiny;
use Data::Dumper;
use URI::Escape;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(
	&tokenizer &fl3_analyzer &fl3_analyzer_word &jspell_analyzer_word
);
our $VERSION = '0.01';

#my $ip_address = "http://localhost:8080/";

#sub tokenizer{
#	my ($text) = @_;
#	my $response = HTTP::Tiny->new->get($ip_address."tokenizer?text=".uri_escape($text));
#	die "Failed!\n" unless $response->{success};
#	return $response->{content} if length $response->{content};
#}

1;
__END__
