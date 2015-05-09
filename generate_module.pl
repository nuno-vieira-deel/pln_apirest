#!/usr/bin/env perl

use XML::DT;
use XML::LibXML;
use Data::Dumper;
use strict;
use warnings;
use experimental 'smartmatch';
use Switch;
use Scalar::Util qw(looks_like_number);
use String::Util qw(trim);
use Capture::Tiny ':all';

my $filename = shift;
my $flag = shift;

## SCHEMA VALIDATION;

my $schema = XML::LibXML::Schema->new(location => 'xml_schema.xsd');
my $parser = XML::LibXML->new;
my $doc = $parser->parse_file($filename);
eval { $schema->validate($doc) };
die $@ if $@;


## MODULE GENERATION;

my $tool;
my $service;
my $fh;
my %hash_info = ();
my %tests = ();
my %documentation = ();
my $aux_test = 0;
my $aux_doc = 0;
my $test_number = 1;
my $last_param = 0;
my $method = 0;
my $packages = "";

$hash_info{hash_token} = "";
$hash_info{subtitle} = "";
$hash_info{description} = "";
$hash_info{input} = "";
$hash_info{output} = "";
$hash_info{cost} = 0;
$hash_info{parameters} = ();
$hash_info{text_cost} = ();


# Variable Reference
# $c - contents after child processing
# $q - element name (tag)
# %v - hash of attributes

my %handler=(
	 '-default'   => sub{""},
	 '-begin' => sub{
			 		if($flag){
			 			switch($flag){
			 				case "-h" { print "HELP!\n"; exit(0);}
			 				case "-d" { print "REMOVING IF EXIST!\n";}
			 			}
			 		}
			 		my %param = ();
    			push @{$hash_info{parameters}}, \%param;
			 	},
	 	'-end'	=> sub{ 
	 									print $fh create_documentation();
	 									close($fh);
 										system("cd modules/intermediate/Spline-$tool; cpanm -S -v .");
 										system("cd modules/Spline-$tool-$service; cpanm -S -v .");
	 								},
    'cost' => sub{ $hash_info{cost} = int($c); },
    'definition' => sub{ $hash_info{description} = $c; },
    'example' => sub{""},
    'route' => sub{ $hash_info{hash_token} = $c; },
    'implementation' => sub{""},
    'input' => sub{ $hash_info{input} = $c; },
    'main' => sub{ 
    								print $fh create_hash_info(%hash_info); 
    								print $fh create_default_functions();
    								print $fh create_main_function($c, $v{lang}, $method);
    						},
    'meta' => sub{
    				if($v{batch}){
    					$v{batch} = 0 if $v{batch} eq 'false';
    					$v{batch} = 1 if $v{batch} eq 'true';
    					$method = $v{batch};
    				}
    	},
    'name' => sub{ 
		     				$service = ucfirst($c);
		     				my @modules = `ls modules`;
		     				if (!("Spline-$tool-$service\n" ~~ @modules)){
	     						system("cd modules; h2xs -XAn Spline::$tool::$service; chmod -R 777 Spline-$tool-$service");
	     						system("cp modules/intermediate/Spline-Services/.gitignore modules/Spline-$tool-$service/");
		     					open($fh, '>', "modules/Spline-$tool-$service/lib/Spline/$tool/$service.pm"); 
		     					print $fh "package Spline::$tool::$service;\n\n";
		     					print $fh "use 5.018002;\nuse strict;\nuse warnings;\nuse JSON;\n\n";
		     				}
		     				else{
		     					system("rm -rf modules/Spline-$tool-$service") if($flag and $flag eq "-d");
		     					print STDERR "This module already exists!\n";
		     					exit(0);
		     				}
		     			}, 
    'output' => sub{ $hash_info{output} = $c; },
    'package' => sub{ 
    				if($method == 0){ print $fh "use $c;\n"; }
    				else{ $packages .= "load '$c'; "; }
    			},
    'packages' => sub{""},
    'default' => sub{ $hash_info{parameters}->[(scalar @{$hash_info{parameters}})-1]{default} = $c; },
    'description' => sub{ $hash_info{parameters}->[(scalar @{$hash_info{parameters}})-1]{description} = $c; },
    'parameter' => sub{ 
    								$hash_info{parameters}->[(scalar @{$hash_info{parameters}})-1]{name} = $v{name};
    								$v{required} = 1 if $v{required} eq 'true';
    								$v{required} = 0 if $v{required} eq 'false';
    								$hash_info{parameters}->[(scalar @{$hash_info{parameters}})-1]{required} = $v{required};
    								my %param = ();
    								push @{$hash_info{parameters}}, \%param;
    							}, # attributes: required
    'parameters' => sub{""},
    'service' => sub{""},
    'subtitle' => sub{ $hash_info{subtitle} = $c; },
    'test' => sub {
		    			create_tests($tool, $service, $aux_test, $test_number, $hash_info{hash_token},  %tests);
		    			%tests = ();
		    			$aux_test = 0;
		    			$test_number++;
		    		},
    'code' => sub {
							push @{$tests{test_code}}, trim($c);
							$aux_test++;
						},
    'param' => sub { $tests{test_param}{$v{name}} = trim($c); },
    'tests' => sub {""},
    'text_cost' => sub{ 
     									my %pair = ();
     									$pair{cost} = $v{cost};
     									$pair{length} = $v{length};
     									push @{$hash_info{text_cost}}, \%pair;
     								}, # attributes: length, cost
    'text_costs' => sub{""},
    'tool' => sub{ 
		     				$tool = ucfirst($c);
		     				my @intermediates = `ls modules/intermediate`;
		     				if (!("Spline-$tool\n" ~~ @intermediates)){
	     						system("cd modules/intermediate; h2xs -XAn Spline::$tool; chmod -R 777 Spline-$tool");
	     						system("cp modules/intermediate/Spline-Services/.gitignore modules/intermediate/Spline-$tool/");
		     				} 
     					},
    'documentation' => sub{""},
    'header' => sub{ 
    								$documentation{$aux_doc}{title} = uc($v{title}); 
    								$documentation{$aux_doc}{content} = $c;
    								$aux_doc++; 
    						},
);
dt($filename, %handler);


sub create_hash_info{
	my ($hash_info) = @_;

	my $hash_token = $hash_info{hash_token};
	my $subtitle = $hash_info{subtitle};
	my $description = $hash_info{description};
	my $input = $hash_info{input};
	my $output = $hash_info{output};
	my $cost = $hash_info{cost};
	my $parameters = $hash_info{parameters};
	my $text_costs = $hash_info{text_cost};

	my $r = "\n";
	$r .= "my %index_info = (\n";
	  $r .= "\thash_token => '$hash_token',\n";
	  $r .= "\tparameters => {\n";
	    $r .= "\t\tapi_token => {\n";
	      $r .= "\t\t\tdescription => 'The token to be identified',\n";
	      $r .= "\t\t\trequired => 1,\n";
	    $r .= "\t\t},\n";
	  for( my $i = 0 ; $i < scalar @{$parameters} ; $i++){
	  	if (defined $parameters->[$i]{name}){
	  		my $aux_name = $parameters->[$i]{name};
	  		my $aux_required = $parameters->[$i]{required};
		  	$r .= "\t\t$aux_name => {\n";
		      $r .= "\t\t\tdescription => '$parameters->[$i]{description}',\n" if(defined $parameters->[$i]{description});
		      $r .= "\t\t\trequired => $aux_required,\n";
		      if(defined $parameters->[$i]{default}){
		      	if (looks_like_number($parameters->[$i]{default})){ $r .= "\t\t\tdefault => $parameters->[$i]{default},\n";}
		      	else {$r .= "\t\t\tdefault => '$parameters->[$i]{default}',\n";}
		      }
		    $r .= "\t\t},\n";
	  	}
	  }
	  $r .= "\t},\n";
	  $r .= "\tsubtitle => '$subtitle',\n" if(!($subtitle eq ""));
	  $r .= "\tdescription => '$description',\n" if(!($description eq ""));
	if(!($input eq "")){
	  $r .= "\texample => {\n";
	    $r .= "\t\tinput => '$input',\n";
	    $r .= "\t\toutput => '$output',\n";
	  $r .= "\t},\n";
	}
	  $r .= "\tcost => $cost,\n";
	if ($text_costs and (scalar @{$text_costs}) > 0){
		$r .= "\ttext_cost => {\n";
		for( my $i = 0 ; $i < scalar @{$text_costs} ; $i++){
			my $aux_len = $text_costs->[$i]{length};
			my $aux_cost = $text_costs->[$i]{cost};
	    $r .= "\t\t$aux_len => $aux_cost,\n";
		}
	  $r .= "\t},\n";
	}
	$r .= ");\n\n";

	return $r;
}

sub create_default_functions{
	my $function = "_".lc($tool)."_".lc($service);
	local $/=undef;
	open(my $fth, "<", "function_template.txt");
	$_ = <$fth>;
	s/service_function/$function/;
	my $result = $_;
	close($fth);
	return $result;
}

sub create_main_function{
	my ($code, $lang, $method) = @_;
	my $parameters = $hash_info{parameters};
	my $result = "";

	$result = "sub _".lc($tool)."_".lc($service)."{\n";
	$result .= "\tmy (\$input_params) = \@_;\n";
	for( my $i = 0 ; $i < scalar @{$parameters} ; $i++){
  	if (defined $parameters->[$i]{name}){
  		my $aux_name = $parameters->[$i]{name};
  		my $aux_required = int($parameters->[$i]{required});
  		$result .=  "\tmy \$$aux_name = \$input_params->{$aux_name};\n";
  		$result .=  "\treturn unless \$$aux_name;\n" if($aux_required==1);
  	}
  }
  $result .= "\n";
  if($method == 0){
		$result .= $code;
	}
	else{
		$result .= "\tmy \$now = time();\n";
		$result .= "\tmy \$ans_json = \"data/json/\".\$now.\".json\";\n";
		$result .= "\tmy \$json = \"public/\".\$ans_json;\n";

		$result .= "\tmy \%status = ();\n";
		$result .= "\t\$status{status} = 'processing';\n";
		$result .= "\t\$status{answer} = \$ans_json;\n\n";

		$result .= "\topen (my \$jfh, \">\", \$json) or die \"cannot open file: \$!\";\n";
			$result .= "\t\tprint \$jfh \"{\\\"status\\\":\\\"processing\\\"}\";\n";
		$result .= "\tclose(\$jfh);\n\n";

		$code =~ s/\\/\\\\/g;
		$code =~ s/\$/\\\$/g;
		$code =~ s/\@/\\\@/g;
		$code =~ s/\%/\\\%/g;
		$code =~ s/\"/\\\"/g;
		$code =~ s/\\\$json/\$json/g; 
		for( my $i = 0 ; $i < scalar @{$parameters} ; $i++){
			if (defined $parameters->[$i]{name}){
				my $aux_name = $parameters->[$i]{name};
				$code =~ s/\\\$$aux_name/\$$aux_name/g;
			}
		}

		$result .= "\topen (my \$dfh, \">\", \"data/queue/\".\$now) or die \"cannot open file: \$!\";\n";
			$result .= "\tprint \$dfh \"$packages\";\n";
			$result .= "\tprint \$dfh \"\\n\";\n";
			$result .= "\tprint \$dfh \"$code\";\n";
		$result .= "\tclose(\$dfh);\n\n";

		$result .= "\treturn \\\%status;\n";
	}
	$result .= "\n}\n\n1;\n__END__";

	return $result;
}

sub create_tests{
	my ($tool, $service, $aux_test, $test_number, $hash_token, %tests) = @_;

	$aux_test++;

	my $tfh;
	open($tfh, '>', "modules/Spline-$tool-$service/t/generated_test".$test_number."_to_".lc($tool)."_".lc($service).".t");

	print $tfh "use strict;\n";
	print $tfh "use warnings;\n";
	print $tfh "use HTTP::Tiny;\n";
	print $tfh "use Data::Dumper;\n";
	print $tfh "use JSON;\n\n";

	print $tfh "use Test::More tests => $aux_test;\n";
	print $tfh "BEGIN { use_ok('Spline::$tool::$service') };\n\n";

	print $tfh "my \$host = \$ENV{SPLINE_HOST} || 'localhost';\n";
	print $tfh "my \$port = \$ENV{SPLINE_PORT} || 8080;\n\n";

	print $tfh "my \%params = ();\n";
	print $tfh "\$params{api_token} = 'MAIlGopQUt';\n";

	for my $param (keys %{$tests{test_param}}){
		print $tfh "\$params{$param} = '".$tests{test_param}{$param}."';\n";
	}

	print $tfh "\nmy \$got = HTTP::Tiny->new->post_form(\"http://\".\$host.\":\".\$port.\"/$hash_token\", \\\%params);\n";
	print $tfh "my \$result = decode_json(\$got->{content});\n\n";

	for my $code (@{$tests{test_code}}){
		print $tfh $code."\n\n";
	}

	close($tfh);
}

sub create_documentation{
	my $result = "";
	for my $num (sort keys %documentation){
		$result .= "\n\n=head1 ".$documentation{$num}{title}."\n\n".$documentation{$num}{content};
	}
	return $result;
}