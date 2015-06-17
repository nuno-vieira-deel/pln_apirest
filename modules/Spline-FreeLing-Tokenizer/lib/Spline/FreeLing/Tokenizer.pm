package Spline::FreeLing::Tokenizer;

use 5.018002;
use strict;
use warnings;
use JSON;

use Lingua::FreeLing3;

my %index_info = (
	hash_token => 'tokenizer',
	parameters => {
		api_token => {
			description => 'The token to be identified',
			required => 1,
			type => 'text',
		},
		text => {
			description => 'The text to be tokenized.',
			required => 1,
			type => 'textarea',
		},
	},
	description => 'This service provides you a way to tokenize your information.',
	cost => 1,
	text_cost => {
		file => [[100,1],[1000,2],],
		api_token => [[2000,3],],
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
  my $tokens = _freeling_tokenizer($input_params);
  return encode_json $tokens;
}

sub _freeling_tokenizer{
	my ($input_params) = @_;
	my $text = $input_params->{text};
	return unless $text;


			my $pt_tok = Lingua::FreeLing3::Tokenizer->new("pt");
  			my $tokens = $pt_tok->tokenize($text, to_text => 1);
  			return $tokens;
  		
}

1;
__END__

=head1 MODULE

Spline::FreeLing::Tokenizer - a module that tokenize your text.

=head1 SYNOPSIS

Just load the Spline main package to your script or send a HTTP POST directly to the Spline platfor and use the tokenizer function/service provided.

=head1 DESCRIPTION

This module provides a way to tokenize the text sent by the user. It is required the text information and the Spline token to use this functionality.