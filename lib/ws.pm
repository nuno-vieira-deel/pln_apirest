package ws;
package API_PLN::Service;

use Dancer2 ':syntax';
use strict;
use warnings;
use Data::Dumper;
use Module::Load;
use Import::Into;
use Class::Factory::Util;

my @modulelist = API_PLN::Service->subclasses;

for my $module (@modulelist){
  autoload "API_PLN::Service::".$module;
}


our $VERSION = '0.1';

my %routemap = (
  'tokenizer' => {
      param_function => sub {
        my (%hparams) = @_;
        #funcao_teste();
        return 1;
      },
      main_function => sub {
        my ($text) = @_;
        my $result = to_json main_function($text);
        return $result;
      }
    }
);


get '/' => sub {
  template 'index';
};

any ['get', 'post'] => '/*' => sub {
  my ($path) = splat; 
  my $val = $routemap{$path}{param_function}->(params);
  my $text = param 'text';
  my $result = $routemap{$path}{main_function}->($text);
  template 'index' => { res => $result };
};



true;
