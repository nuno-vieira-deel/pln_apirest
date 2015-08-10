package Spline::Text::WordReplace;

use 5.018002;
use strict;
use warnings;
use JSON;
use utf8;
use Encode qw(decode_utf8);


my %index_info = (
	hash_token => 'word-replace',
	parameters => {
		api_token => {
			description => 'The token to be identified',
			required => 1,
			type => 'text',
		},
		file => {
			description => 'The file to be treated.',
			required => 1,
			type => 'file',
		},
		old_word => {
			description => 'The word to be replaced.',
			required => 1,
			type => 'text',
		},
		new_word => {
			description => 'The new word.',
			required => 1,
			type => 'text',
		},
	},
	description => 'Substitute description.',
	cost => 2,
	text_cost => {
		file => [[1000,1],],
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
  my $result = _text_wordreplace($input_params);
  my $json = encode_json $result;
  return decode_utf8($json);
}

sub _text_wordreplace{
	my ($input_params) = @_;
	my $file = $input_params->{file};
	return unless $file;
	my $old_word = $input_params->{old_word};
	return unless $old_word;
	my $new_word = $input_params->{new_word};
	return unless $new_word;

	my $ID = time();
	my $ans_json = "data/json/".$ID.".json";
	my $json = "public/".$ans_json;
	my %status = ();
	$status{status} = 'processing';
	$status{answer} = $ans_json;

	open (my $jfh, ">", $json) or die "cannot open file: $!";
		print $jfh "{\"status\":\"processing\", \"result\":[\"data/results/$ID/result.txt\"]}";
	close($jfh);

	system("mkdir public/data/results/$ID");
	open (my $dfh, ">", "data/queue/".$ID) or die "cannot open file: $!";
	print $dfh "";
	print $dfh "\n";
	print $dfh "
				system(\"perl -pi -e 's/$old_word/$new_word/g' $file\");
				system(\"cp $file public/data/results/$ID/result.txt\");
  	";
	print $dfh "\n";
	print $dfh "system(\"perl -pi -e 's/\\\"status\\\":\\\"processing\\\"/\\\"status\\\":\\\"done\\\"/' $json \");";
	close($dfh);

	return \%status;

}

1;
__END__