package ws;
package API_PLN::Service;

use Dancer2 ':syntax';
use strict;
use warnings;
use Data::Dumper;
use Module::Load;
use Import::Into;
use Class::Unload;
use Class::Factory::Util;

our $VERSION = '0.1';

my %routemap = ();
my %indexmap = ();

my @modulelist = API_PLN::Service->subclasses;

for my $module (@modulelist){
  my $loadmodule = "API_PLN::Service::".$module;
  load $loadmodule;
  my $hash_token = $loadmodule->get_token();
  $indexmap{$hash_token} = $loadmodule->get_info();
  $routemap{$hash_token}{param_function} = $loadmodule->can("param_function");
  $routemap{$hash_token}{main_function}  = $loadmodule->can("main_function");
  Class::Unload->unload($loadmodule);
}

get '/' => sub {
  template 'index' => {
    tools => \%indexmap
  };
};

get '/info' => sub {
  my @array = keys %routemap;
  return to_json (\@array);
};

any ['get', 'post'] => '/*' => sub {
  my ($path) = splat; 
  my @error = ();
  my $result = to_json(\@error);
  my %input_params = params;
  my $val = $routemap{$path}{param_function}->(\%input_params);
  if ($val==1){
    $result = $routemap{$path}{main_function}->(\%input_params);
  }
  #template 'index' => { res => $result };
  return $result;
};


true;
