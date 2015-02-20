package Spline::FreeLing::AnalyzerWord;

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
  hash_token => 'fl3_word_analyzer',
  parameters => {
    api_token => {
      description => 'The token to be indentified',
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
  },
  subtitle => 'Subtitulo de fl3_word_analyzer',
  description => 'Descricao de fl3_word_analyzer',
  example => {
    input => 'input',
    output => '[{"cat":"n","word":"input","lemma":"input","pos":"NCMS000"}]',
  },
  cost => 3,
  text_cost => {
    20 => 1,
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
  my $text_length = length($input_params->{word});

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
  my ($input_params) = @_;
  my %options = ( lang=>'pt' );
  my $result = _fl3_analyzer_word($input_params->{word}, %options);
  return encode_json $result;
}

sub _fl3_analyzer_word {
  my ($word, %options) = @_;
  return unless $word;

  my $words = tokenizer($options{lang})->tokenize($word);
  
  my $analysis = $fl3_morph_pt->analyze([Lingua::FreeLing3::Sentence->new(@$words)]);
  my @w = $analysis->[0]->words;
  my $result =  $w[0]->analysis(FeatureStructure=>1);

  my @final;
  foreach (@$result) {
    my $pos = $_->{tag};
    my $lemma = $_->{lemma};
    my $cat = '_';
    $cat = lc($1) if $pos =~ m/^(\w)/;
    push @final, {lemma=>$lemma, pos=>$pos, cat=>$cat, word=>$word};
  }

  return [@final];
}


1;
__END__