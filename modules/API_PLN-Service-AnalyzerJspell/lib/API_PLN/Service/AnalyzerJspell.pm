package API_PLN::Service::AnalyzerJspell;

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

my $hash_token = 'jspell_analyzer';
my %parameters = ( 
    text => {
      description => 'The text to be analyzed',
      required => 1,
    },
    word => {
      description => 'The word to be analyzed',
      required => 1,
    },
    ner => {
      description => 'Named-entity recognition',
      required => 0,
    },
 );

sub get_token {
  return $hash_token;
}

sub param_function {
	#return sub {
	    my ($input_params) = @_;
	    my $flag = 0;
	    for my $param (keys %parameters){
	      if ($parameters{$param}{required} == 1){
	        $flag++ if (exists($input_params->{$param}));
	      }
	    }
	    return $flag;
	#}
}

sub main_function {
	#return sub {
		my ($input_params) = @_;
		if(exists $input_params->{word}){
			my %options = ( lang=>'pt' );
			my $result = _jspell_analyzer_word($input_params->{word}, %options);
			return encode_json $result;
		}
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
