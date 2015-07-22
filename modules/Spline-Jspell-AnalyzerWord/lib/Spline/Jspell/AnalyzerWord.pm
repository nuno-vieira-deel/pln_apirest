package Spline::Jspell::AnalyzerWord;

use 5.018002;
use strict;
use warnings;
use JSON;
use utf8;
use Encode qw(decode_utf8);
use Lingua::Jspell;

my %index_info = (
  hash_token => 'jspell_word_analyzer',
  parameters => {
    api_token => {
      description => 'The token to be indentified',
      required => 1,
      type => 'text',
    },
    word => {
      description => 'The word to be analyzed',
      required => 1,
      type => 'text',
    },
  },
  subtitle => 'Subtitulo de jspell_word_analyzer',
  description => 'Descricao de jspell_word_analyzer',
  cost => 2,
  text_cost => {
    word => [[30,1]],
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
    my $text_length = "";
    if($index_info{parameters}{$param}{type} eq 'file'){ 
      $text_length = -s "$input_params->{$param}";
    }
    else{ 
      $text_length = length($input_params->{$param});
    }
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
	my $result = _jspell_analyzer_word($input_params);
	my $json = encode_json $result;
  return decode_utf8($json);
}

sub _jspell_analyzer_word {
  my ($input_params) = @_;
  my $word = $input_params->{word};
  return unless $word;

  my $jspell_dict = Lingua::Jspell->new("pt_PT");
  my %options = ( lang=>'pt' );
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
