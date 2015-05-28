package Spline::FreeLing::Analyzer;

use 5.018002;
use strict;
use warnings;
use JSON;
use FL3 'pt';

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
      default => 0,
    },
  },
  subtitle => 'Subtitulo de fl3_analyzer',
  description => 'Descricao de fl3_analyzer',
  cost => 2,
  text_cost => {
    text => [[500,1],[1000,2]],
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

  for my $param (keys %{$index_info{text_cost}}){
    my $text_length = length($input_params->{$param});
    for my $pair (@{$index_info{text_cost}{$param}}){
      if($text_length >= int($pair->[0])){
        $cost_result += $pair->[1];
      }
    }
  }

  my $final_cost = $cost_result + $index_info{cost};
  return $final_cost;
}

sub param_function {
  my ($input_params) = @_;
  my $flag = 1;
  for my $param (keys %{$index_info{parameters}}){
    if ($index_info{parameters}{$param}{required} == 1){
      $flag = 0 if (!exists($input_params->{$param}));
    }
    if ($index_info{parameters}{$param}{default}){
      $input_params->{$param} = $index_info{parameters}{$param}{default} if (!exists($input_params->{$param}));
    }
  }
  return $flag;
}

sub main_function {
	my ($input_params) = @_;
	my $result = _fl3_analyzer($input_params);
	return encode_json $result;
}


sub _fl3_analyzer {
  my ($input_params) = @_;
  my $text = $input_params->{text};
  my $ner = $index_info{parameters}{ner}{default};
  $ner = $input_params->{ner} if exists $input_params->{ner};
  return unless $text;

  my %options = ( lang => 'pt', ner => $ner );

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
