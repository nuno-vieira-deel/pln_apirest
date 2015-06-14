package Spline::Test::NewTest;

use 5.018002;
use strict;
use warnings;
use JSON;

use Lingua::NATools;

my %index_info = (
	hash_token => 'new_test',
	parameters => {
		api_token => {
			description => 'The token to be identified',
			required => 1,
			type => 'text',
		},
		file => {
			description => 'The file to be treated',
			required => 1,
			type => 'file',
		},
		ner => {
			description => 'The NER.',
			required => 0,
			type => 'number',
			default => 1,
		},
	},
	description => 'Descricao.',
	cost => 20,
	text_cost => {
		api_token => [[2000,2],],
		file => [[1000,1],[2000,2],],
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
  my $tokens = _test_newtest($input_params);
  return encode_json $tokens;
}

sub _test_newtest{
	my ($input_params) = @_;
	my $file = $input_params->{file};
	return unless $file;
	my $ner = $input_params->{ner};

	system("echo \"$ner\n\";			echo \"adeus\n\";  	");
	my %status = ();
	$status{status} = 'done';
	return \%status;

}

1;
__END__

=head1 MODULE

Spline::NATools::NATCreate - a module to create ...

=head1 SYNOPSIS

NATCreate synopsis

=head1 DESCRIPTION

NATCreate description

=head1 AUTHOR

NATCreate Author

=head1 SEE ALSO

Other modules