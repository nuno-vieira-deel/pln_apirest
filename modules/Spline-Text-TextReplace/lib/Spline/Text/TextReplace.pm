package Spline::Text::TextReplace;

use 5.018002;
use strict;
use warnings;
use JSON;
use utf8;
use Encode qw(decode_utf8);


my %index_info = (
	hash_token => 'text-replace',
	parameters => {
		api_token => {
			description => 'The token to be identified',
			required => 1,
			type => 'text',
		},
		text => {
			description => 'The text to be edited.',
			required => 1,
			type => 'textarea',
		},
		old_expr => {
			description => 'The expression to be replaced.',
			required => 1,
			type => 'text',
		},
		new_expr => {
			description => 'The new content.',
			required => 1,
			type => 'text',
		},
	},
	description => 'Substitute description.',
	cost => 2,
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
  my $result = _text_textreplace($input_params);
  my $json = encode_json $result;
  return decode_utf8($json);
}

sub _text_textreplace{
	my ($input_params) = @_;
	my $text = $input_params->{text};
	return unless $text;
	my $old_expr = $input_params->{old_expr};
	return unless $old_expr;
	my $new_expr = $input_params->{new_expr};
	return unless $new_expr;

	my $ID = time();
	system("mkdir public/data/results/$ID");

				my %res = ();
				$res{result} = `echo \"$text\" | perl -p -e 's/$old_expr/$new_expr/g'`;
				return \%res;
  	
}

1;
__END__