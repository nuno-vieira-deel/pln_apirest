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
  my ($input_params) = @_;
  my $flag = 1;
  for my $param (keys %{$index_info{parameters}}){
    if ($index_info{parameters}{$param}{required} == 1){
      $flag = 0 if (!exists($input_params->{$param}));
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
  my $ner = 0;
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
