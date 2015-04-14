package Spline::Tool::Tokenizer2;

use 5.018002;
use strict;
use warnings;
use JSON;

use FL3 'pt';
use Lingua::FreeLing3::Sentence;
use Lingua::FreeLing3::Utils qw/word_analysis/;

my %index_info = (
	hash_token => 'tokenizer2',
	parameters => {
		api_token => {
			description => 'The token to be identified',
			required => 1,
		},
		text => {
			description => 'The text to be tokenized',
			required => 1,
		},
		outro => {
			description => 'Other argument',
			required => 0,
			default => 'default value',
		},
	},
	description => 'Process of breaking a stream of text up into tokens.',
	cost => 1,
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
  my $tokens = _tool_tokenizer2($input_params);
  return encode_json $tokens;
}

sub _tool_tokenizer2{
	my ($input_params) = @_;
	my $text = $input_params->{text};
	return unless $text;
	my $outro = $input_params->{outro};


			my $pt_tok = Lingua::FreeLing3::Tokenizer->new("pt");
		  	my $tokens = $pt_tok->tokenize($text, to_text => 1);
		  	return $tokens;
	  	
}

1;
__END__