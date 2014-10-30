package ws;
use Dancer2 ':syntax';

use strict;
use warnings;
use Data::Dumper;
use Module::Load;
use Import::Into;


our $VERSION = '0.1';

my %routemap = (
  'tokenizer' => sub {
      my ($text) = @_;
      autoload API_PLN::Service::TokenizerFL3;
      my $result = to_json main_function($text);
      return $result;
    }
);


get '/' => sub {
  template 'index';
};

any ['get', 'post'] => '/*' => sub {
  my ($path) = splat;
  #my $text = param 'text';
  my $text = "Eu sou o Nuno.";
  my $result = $routemap{$path}->($text);
  template 'index' => { res => $result };
};



true;
