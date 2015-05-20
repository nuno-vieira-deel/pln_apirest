package Spline::Test::NewTest;

use 5.018002;
use strict;
use warnings;
use JSON;

use Lingua::NATools;

my %index_info = (
	hash_token => 'new-test',
	parameters => {
		api_token => {
			description => 'The token to be identified',
			required => 1,
		},
		file => {
			description => 'The file to be treated',
			required => 1,
		},
	},
	description => 'Descricao.',
	cost => 20,
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

  my $text_length = 0;
  $text_length = length($input_params->{word}) if(defined $input_params->{word});
  $text_length = length($input_params->{text}) if(defined $input_params->{text});

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
  my $tokens = _test_newtest($input_params);
  return encode_json $tokens;
}

sub _test_newtest{
	my ($input_params) = @_;
	my $file = $input_params->{file};
	return unless $file;

	system("echo \"ola\n\";			echo \"adeus\n\";  	");
	my %status = ();
	$status{status} = 'processing';
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