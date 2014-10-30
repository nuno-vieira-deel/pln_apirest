package API_PLN::Service::TokenizerFL3;

use 5.018002;
use strict;
use warnings;

use FL3 'pt';
use Lingua::FreeLing3::Sentence;
use Lingua::FreeLing3::Utils qw/word_analysis/;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	&main_function
);

our $VERSION = '0.01';

sub main_function {
  my ($text) = @_;
  my $tokens = _fl3_tokenizer($text);
  return $tokens;
}

sub _fl3_tokenizer {
  my ($text) = @_;
  return unless $text;

  my $pt_tok = Lingua::FreeLing3::Tokenizer->new("pt");
  my $tokens = $pt_tok->tokenize($text, to_text => 1);

  return $tokens;
}

1;
__END__
