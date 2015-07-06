package Spline::Test::NewTest;

use 5.018002;
use strict;
use warnings;
use JSON;
use utf8;
use Encode qw(decode_utf8);


my %index_info = (
	hash_token => 'new_test',
	parameters => {
		api_token => {
			description => 'The token to be identified',
			required => 1,
			type => 'text',
		},
		text => {
			description => 'The text to be tokenized.',
			required => 0,
			type => 'textarea',
		},
	},
	description => 'This service provides you a way to tokenize your information.',
	cost => 1,
	text_cost => {
		text => [[100,1],[1000,2],],
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
  my $result = _test_newtest($input_params);
  my $json = encode_json $result;
  return decode_utf8($json);
}

sub _test_newtest{
	my ($input_params) = @_;
	my $text = $input_params->{text};

	my $now = time();
	my $ans_json = "data/json/".$now.".json";
	my $json = "public/".$ans_json;
	my %status = ();
	$status{status} = 'processing';
	$status{answer} = $ans_json;

	open (my $jfh, ">", $json) or die "cannot open file: $!";
		print $jfh "{\"status\":\"processing\", \"result\":[\"public/data/results/ficheiro.txt\"]}";
	close($jfh);

	open (my $dfh, ">", "data/queue/".$now) or die "cannot open file: $!";
	print $dfh "system(\"
				echo \\\"$text\\\"
  	\");";
	print $dfh "\n";
	print $dfh "system(\"perl -pi -e 's/\\\"status\\\":\\\"processing\\\"/\\\"status\\\":\\\"done\\\"/' $json \");";
	close($dfh);

	return \%status;

}

1;
__END__