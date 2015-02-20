package Spline::FreeLing::Analyzer;

use 5.018002;
use strict;
use warnings;
use JSON;
use URI::Escape;
use FL3 'pt';
use Lingua::FreeLing3::Sentence;
use Lingua::FreeLing3::Utils qw/word_analysis/;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

my $fl3_morph_pt = Lingua::FreeLing3::MorphAnalyzer->new('pt',
    ProbabilityAssignment  => 0, QuantitiesDetection    => 0,
    MultiwordsDetection    => 0, NumbersDetection       => 0,
    DatesDetection         => 0, NERecognition          => 0,
  );


my %index_info = (
  hash_token => 'fl3_analyzer',
  parameters => {
    api_token => {
      description => 'The token to be indentified',
      required => 1,
    },
    text => {
      description => 'The text to be analyzed',
      required => 1,
    },
    ner => {
      description => 'Named-entity recognition',
      required => 0,
    },
  },
  subtitle => 'Subtitulo de fl3_analyzer',
  description => 'Descricao de fl3_analyzer',
  example => {
    input => 'O input.',
    output => '[{"lemma":"o","pos":"DA0MS0","word":"O"},{"lemma":"input","pos":"NCMS000","word":"input"},{"pos":"Fp","lemma":".","word":"."}]',
  },
  cost => 2,
  text_cost => {
    500 => 1,
    1000 => 2,
  },
);

sub get_token {
  return $index_info{hash_token};
}

sub get_info {
  return \%index_info;
}

sub cost_function{
  my ($input_params) = @_;
  my $cost_result = 0;
  my $text_length = length($input_params->{text});

  for my $cost (keys %{$index_info{text_cost}}){
    if($text_length >= int($cost)){
      $cost_result = int($index_info{text_cost}{$cost});
    }
    else{
      last;
    }
  }

  my $final_cost = $cost_result + int($index_info{cost});
  return $final_cost;
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
		my $text = $input_params->{text};
		my $ner = 0;
		$ner = $input_params->{ner} if exists $input_params->{ner};
		my %options = ( lang => 'pt', ner => $ner );
		my $result = _fl3_analyzer($text, %options);
		return encode_json $result;
	#}
}


sub _fl3_analyzer {
  my ($text, %options) = @_;
  return unless $text;

  my $morph = Lingua::FreeLing3::MorphAnalyzer->new($options{lang},
      NERecognition => $options{ner},
    );

  my $tokens = tokenizer->tokenize($text);
  my $sentences = splitter->split($tokens);
  $sentences = $morph->analyze($sentences);
  $sentences = hmm->analyze($sentences);

  my $result;
  foreach (@$sentences) {
    my @words = $_->words;
    foreach my $w (@words) {
      push @$result, {word=>$w->form, pos=>$w->tag, lemma=>$w->lemma};
    }
  }

  return $result;
}

1;
__END__
