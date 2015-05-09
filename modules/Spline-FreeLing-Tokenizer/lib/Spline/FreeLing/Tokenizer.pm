package Spline::FreeLing::Tokenizer;

use 5.018002;
use strict;
use warnings;
use JSON;

my %index_info = (
  hash_token => 'tokenizer',
  parameters => {
    api_token => {
      description => 'The token to be indentified',
      required => 1,
    },
    text => {
      description => 'The text to be tokenized',
      required => 1,
    },
  },
  subtitle => 'Subtitulo de tokenizer',
  description => 'Descricao de tokenizer',
  example => {
    input => 'O input.',
    output => '["O","input","."]',
  },
  cost => 1,
  text_cost => {
    100 => 1,
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
      $cost_result = $index_info{text_cost}{$cost};
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
  }
  return $flag;
}

sub main_function {
  my ($input_params) = @_;
  my $tokens = _fl3_tokenizer($input_params);
  return encode_json $tokens;
}

sub _fl3_tokenizer {
  my ($input_params) = @_;
  my $text = $input_params->{text};
  return unless $text;

  my $pt_tok = Lingua::FreeLing3::Tokenizer->new("pt");
  my $tokens = $pt_tok->tokenize($text, to_text => 1);

  return $tokens;
}

1;
__END__
