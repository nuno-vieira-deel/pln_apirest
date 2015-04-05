package Spline::Jspell::AnalyzerWord;

use 5.018002;
use strict;
use warnings;
use JSON;
use Lingua::Jspell;

my %index_info = (
  hash_token => 'jspell_word_analyzer',
  parameters => {
    api_token => {
      description => 'The token to be indentified',
      required => 1,
    },
    word => {
      description => 'The word to be analyzed',
      required => 1,
    },
  },
  subtitle => 'Subtitulo de jspell_word_analyzer',
  description => 'Descricao de jspell_word_analyzer',
  example => {
    input => 'input',
    output => '[{"word":"input","pos":"NCMS","lemma":"input","cat":"n"}]',
  },
  cost => 2,
  text_cost => {
    30 => 1,
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
	my $result = _jspell_analyzer_word($input_params);
	return encode_json $result;
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
