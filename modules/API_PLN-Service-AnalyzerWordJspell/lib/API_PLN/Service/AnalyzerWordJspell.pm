package API_PLN::Service::AnalyzerWordJspell;

use 5.018002;
use strict;
use warnings;
use JSON;
use URI::Escape;
use Lingua::Jspell;

require Exporter;

our @ISA = qw(Exporter);


our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

my $jspell_dict = Lingua::Jspell->new("pt_PT");


my %index_info = (
  hash_token => 'jspell_word_analyzer',
  parameters => {
    word => {
      description => 'The word to be analyzed',
      required => 1,
    },
    ner => {
      description => 'Named-entity recognition',
      required => 0,
    },
  },
  subtitle => 'Subtitulo de jspell_word_analyzer',
  description => 'Descricao de jspell_word_analyzer',
  example => {
    input => 'input',
    output => '[{"word":"input","pos":"NCMS","lemma":"input","cat":"n"}]',
  },
);

sub get_token {
  return $index_info{hash_token};
}

sub get_info {
  return \%index_info;
}

sub param_function {
#  return sub {
    my ($input_params) = @_;
    my $flag = 1;
    for my $param (keys %{$index_info{parameters}}){
      if ($index_info{parameters}{$param}{required} == 1){
        $flag = 0 if (!exists($input_params->{$param}));
      }
    }
    return $flag;
 # }
}

sub main_function {
	#return sub {
		my ($input_params) = @_;
		my %options = ( lang=>'pt' );
		my $result = _jspell_analyzer_word($input_params->{word}, %options);
		return encode_json $result;
	#}
}

sub _jspell_analyzer_word {
  my ($word, %options) = @_;

  my $result;

  foreach ( $jspell_dict->featagsrad($word) ) {
    my ($pos, $lemma) = split /:/, $_;
    my $cat = '_';
    $cat = lc($1) if $pos =~ m/^(\w)/;
    push @$result, {lemma=>$lemma, pos=>$pos, cat=>$cat, word=>$word};
  }

  return $result;
}


1;
__END__