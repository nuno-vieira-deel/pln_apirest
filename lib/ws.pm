package ws;
package API_PLN::Service;

use Dancer2 ':syntax';
use strict;
use warnings;
use Data::Dumper;
use Module::Load;
use Import::Into;
use Class::Factory::Util;

our $VERSION = '0.1';

my %routemap = ();

my @modulelist = API_PLN::Service->subclasses;

for my $module (@modulelist){
  my $loadmodule = "API_PLN::Service::".$module;
  load $loadmodule;
  my $hash_token = $loadmodule->get_token();
  $routemap{$hash_token}{param_function} = $loadmodule->param_function();
  $routemap{$hash_token}{main_function} = $loadmodule->main_function();
}


get '/' => sub {
  template 'index';
};

any ['get', 'post'] => '/*' => sub {
  my ($path) = splat; 
  my $result = "Error";
  my %input_params = params;
  my $val = $routemap{$path}{param_function}->(\%input_params);
  if ($val==1){
    $result = $routemap{$path}{main_function}->(\%input_params);
  }
  template 'index' => { res => $result };
};



true;
