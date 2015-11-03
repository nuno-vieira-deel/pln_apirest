#!/usr/bin/env perl

#to do:
# 1. Tratar > e < XML tags
# 2. Adicionar batch tags


use strict;
use warnings;
use Term::Menu;
use XML::LibXML;

my $prompt = new Term::Menu;

print "\nBem vindo à interface de gestão de serviços do SplineAPI!\n\n";

my $answer = $prompt->menu(
   normal  	 =>      ["Create a new normal service", 1],
   batch 	 =>      ["Create a new batch service", 2],
   quit   	 =>      ["Quit", 3],
);
my $menu_answer = $prompt->lastval;

exit(0) if($menu_answer eq 'quit');

my $isBatch = 0;
$isBatch = 1 if($menu_answer eq 'batch');
my $answers;

my $doc = XML::LibXML::Document->new('1.0', 'utf8');
my $root = new_element("service", $doc);
my $meta = new_element("meta", $root);
$meta->setAttribute('batch', $isBatch);

$answers = prompt_question("What is the tool name? ");
new_text_element("tool", $answers, $meta);

$answers = prompt_question("What is the service name? ");
new_text_element("name", $answers, $meta);

$answers = prompt_question("What is the route? ");
new_text_element("route", $answers, $meta);

my $params = new_element("parameters", $meta);
my $counter = int(prompt_question("How many parameters will the service have? "));

for(my $i = 0; $i < $counter; $i++){
	my $param = new_element("parameter", $params);

	$answers = prompt_question("What is the parameter ".($i+1)." name? ");
	$param->setAttribute('name', $answers);

	$answers = prompt_question("Is the parameter ".($i+1)." required? [y|n] ");
	$param->setAttribute('required', 0) if($answers eq 'n' or $answers eq 'N');
	$param->setAttribute('required', 1) if($answers eq 'y' or $answers eq 'Y');

	$answers = prompt_question("What is the parameter ".($i+1)." type (HTML)? ");
	$param->setAttribute('type', $answers);

	$answers = prompt_question("What is the parameter ".($i+1)." description? ");
	new_text_element("description", $answers, $param);

	$answers = prompt_question("What is the parameter ".($i+1)." default value? ");
	new_text_element("default", $answers, $param);
}

$answers = prompt_question("What is the tool definition? ");
new_text_element("definition", $answers, $meta);

$answers = prompt_question("What is the service cost? ");
new_text_element("cost", $answers, $meta);

my $textcosts = new_element("text_costs", $meta);
$counter = int(prompt_question("How many text-cost pairs will the service have? "));

for(my $i = 0; $i < $counter; $i++){
	my $textcost = new_element("text_cost", $textcosts);

	$answers = prompt_question("What is the text-cost ".($i+1)." field? ");
	$textcost->setAttribute('field', $answers);

	$answers = prompt_question("What is the text-cost ".($i+1)." length? ");
	$textcost->setAttribute('length', $answers);

	$answers = prompt_question("What is the text-cost ".($i+1)." cost? ");
	$textcost->setAttribute('cost', $answers);
}


my $implementation = new_element("implementation", $root);

my $packages = new_element("packages", $implementation);
$counter = int(prompt_question("How many packages will the service have? "));

for(my $i = 0; $i < $counter; $i++){
	$answers = prompt_question("What is the package ".($i+1)." name? ");
	new_text_element("package", $answers, $packages);
}


$answers = prompt_question("Insert the code to run: ");
my $main = new_text_element("main", $answers, $implementation);
$answers = prompt_question("What language will be used? [perl|bash] ");
$main->setAttribute('lang', $answers);


if($isBatch == 1){
	my $output = new_element("output", $implementation);

	$counter = int(prompt_question("How many files will the output have? "));

	for(my $i = 0; $i < $counter; $i++){
		$answers = prompt_question("What is the file path? ");
		$output->new_text_element('file', $answers);
	}

	$counter = int(prompt_question("How many dirs will the output have? "));

	for(my $i = 0; $i < $counter; $i++){
		$answers = prompt_question("What is the dir path? ");
		$output->new_text_element('dir', $answers);
	}	
}


my $tests = new_element("tests", $root);
$counter = int(prompt_question("How many tests will the service have? "));

for(my $i = 0; $i < $counter; $i++){
	my $test = new_element("test", $tests);

	my $counter2 = int(prompt_question("How many params will the test ".($i+1)." have? "));

	for(my $j = 0; $j < $counter2; $j++){
		$answers = prompt_question("What is the param ".($j+1)." code of the test ".($i+1)."? ");
		my $testparam = new_text_element("param", $answers, $test);

		$answers = prompt_question("What is the param ".($j+1)." name of the test ".($i+1)."? ");
		$testparam->setAttribute("param", $answers);
	}

	$counter2 = int(prompt_question("How many verifications will the test ".($i+1)." have? "));

	for(my $j = 0; $j < $counter2; $j++){
		$answers = prompt_question("What is the verification ".($j+1)." code of the test ".($i+1)."? ");
		new_text_element("code", $answers, $test);
	}
}


my $documentation = new_element("documentation", $root);
$counter = int(prompt_question("How many documentation headers will the service have? "));

for(my $i = 0; $i < $counter; $i++){
	$answers = prompt_question("What is the header ".($i+1)." content? ");
	my $header = new_text_element("header", $answers, $documentation);

	$answers = prompt_question("What is the header ".($i+1)." title? ");
	$header->setAttribute("title", $answers);
}

my $fh;
open $fh, ">", "xmlTmp.xml";
print $fh $doc->toString;
system("perl generate_module.pl xmlTmp.xml");
system("rm xmlTmp.xml");
close($fh);



sub prompt_question{
	my ($question) = @_;
	my $answer = $prompt->question($question);
	chomp($answer);
	return $answer;
}

sub new_element{
	my ($name, $parent) = @_;
	my $xmlElement = $doc->createElement($name);
	$parent->addChild($xmlElement);
	return $xmlElement;
}

sub new_text_element{
	my ($name, $content, $parent) = @_;
	my $xmlElement = $doc->createElement($name);
	$parent->addChild($xmlElement);
	$xmlElement->addChild($doc->createTextNode($content));
	return $xmlElement;
}