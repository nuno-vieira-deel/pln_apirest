package Spline::NATools::NATCreate;

use 5.018002;
use strict;
use warnings;
use JSON;
use utf8;
use Encode qw(decode_utf8);


my %index_info = (
	hash_token => 'nat-create',
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
  my $result = _natools_natcreate($input_params);
  my $json = encode_json $result;
  return decode_utf8($json);
}

sub _natools_natcreate{
	my ($input_params) = @_;
	my $file = $input_params->{file};
	return unless $file;

	my $now = time();
	my $ans_json = "data/json/".$now.".json";
	my $json = "public/".$ans_json;
	my %status = ();
	$status{status} = 'processing';
	$status{answer} = $ans_json;

	open (my $jfh, ">", $json) or die "cannot open file: $!";
		print $jfh "{\"status\":\"processing\"}";
	close($jfh);

	open (my $dfh, ">", "data/queue/".$now) or die "cannot open file: $!";
	print $dfh "load 'Lingua::NATools'; ";
	print $dfh "\n";
	print $dfh "system(\"nat-create -tokenize -id=public/data/results/1111 -tmx $file\");
			open(my \$fh, \">\", \"$json\");
				my \%status = ();
				\$status{status} = 'done';
				my \@array = (\"data/results/1111/target-source.dmp\", \"data/results/1111/target-target.dmp\");
				\$status{ans} = \\\@array;
				print \$fh encode_json(\\\%status);
			close(\$fh);
  	";
	close($dfh);

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