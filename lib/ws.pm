package ws;
package API_PLN::Service;

use Dancer2 ':syntax';
use strict;
use warnings;
use Data::Dumper;
use Module::Load;
use Import::Into;
use Class::Factory::Util;
use Sub::Install;
use HTTP::Tiny;
use URI::Escape;

our $VERSION = '0.1';

my %routemap = ();

my $ip_address = "http://localhost:8080/";

my @modulelist = API_PLN::Service->subclasses;

for my $module (@modulelist){
  my $loadmodule = "API_PLN::Service::".$module;
  load $loadmodule;
  my $hash_token = $loadmodule->get_token();
  $routemap{$hash_token}{param_function} = $loadmodule->can("param_function");
  $routemap{$hash_token}{main_function}  = $loadmodule->can("main_function");

  Sub::Install::install_sub({
    code => sub { 
      my (%input_params) = @_;
      if($routemap{$hash_token}{param_function}==1){
        my $url = $ip_address."".$hash_token;
        my $flag = 0;
        for my $parameter (keys %input_params){
          if($flag==0){
            $url .= "?".$parameter."=".uri_escape($input_params{$parameter});
            $flag++;
          }
          else{
            $url .= "&".$parameter."=".uri_escape($input_params{$parameter});
          }
        }
        my $response = HTTP::Tiny->new->get($url);
        die "Failed!\n" unless $response->{success};
        return $response->{content} if length $response->{content};
      }
      else{
        die "Failed\n";
      }
    },
    into => "API_PLN::Services",
    as   => $hash_token,
  });
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
  #template 'index' => { res => $result };
  return $result;
};


true;
