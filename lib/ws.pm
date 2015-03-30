package ws;
package Spline;

use Dancer2 ':syntax';
use strict;
use warnings;
use Data::Dumper;
use Module::Load;
use Import::Into;
use Class::Unload;
use Class::Factory::Util;
use Digest::SHA qw(sha1 sha256_hex);

use Dancer2::Plugin::Emailesque;
use Dancer2::Plugin::Database;
our $VERSION = '0.1';

my $request_limit = 1000;
my %routemap = ();
my %indexmap = ();

my @classes = Spline->subclasses;

for my $c (@classes) {
   my $class = "Spline::$c";

   my @x = eval "package $class;\n use Class::Factory::Util; $class->subclasses;";

   for my $sc (@x) {
      my $loadmodule = "$class::$sc";
      load $loadmodule;
      my $hash_token = $loadmodule->get_token();
      $indexmap{$hash_token} = $loadmodule->get_info();
      $routemap{$hash_token}{param_function} = $loadmodule->can("param_function");
      $routemap{$hash_token}{main_function}  = $loadmodule->can("main_function");
      $routemap{$hash_token}{cost_function}  = $loadmodule->can("cost_function");
      Class::Unload->unload($loadmodule);
   }
}

####### URLs Dancer

get '/' => sub {
  template 'index' => {
    tools => \%indexmap
  };
};

get '/info' => sub {
  my @array = keys %routemap;
  return to_json (\@array);
};

get '/register' => sub {
  template 'sign_in' => {
  };
};

post '/sign_in' => sub {
  my %input_params = params;
  my $user_email = $input_params{email};

  #if (!$input_params{'g-recaptcha-response'} eq ''){
    if (has_user($user_email) == 0){
      add_user($user_email);
      redirect '/';
    }
    else{
      redirect '/register';
    }
  #}

  redirect '/register';
};

any ['get', 'post'] => '/*' => sub {
  my ($path) = splat; 
  my @error = ();
  my $result = to_json(\@error);
  my %input_params = params;
  my $val = $routemap{$path}{param_function}->(\%input_params);
  if ($val==1){
    my $cost = $routemap{$path}{cost_function}->(\%input_params);
    if(do_request($input_params{api_token}, $cost) == 1){
      $result = $routemap{$path}{main_function}->(\%input_params);
    }
  }
  return $result;
};

true;

# AUXILIAR FUNCTIONS

sub do_request{
  my ($api_token, $cost) = @_;
  my $encryptoken = sha256_hex($api_token);

  my $row = database->quick_select('api_users', { api_token => $encryptoken });
  return 0 if(!$row->{email});
  my $old_requests = $row->{requests};

  if($request_limit-($old_requests+$cost) >= 0){
    my $new_requests = $old_requests + $cost;
    database->quick_update('api_users', { email => $row->{email} }, { requests => $new_requests });
    return 1;
  }
  else{ return 0; }

}

sub has_user{
  my $user_email = shift;
  my $result = database->quick_count('api_users', {email => $user_email});
  return $result;
}

sub add_user{
  my $user_email = shift;
  my @chars = ("A".."Z", "a".."z");
  my $string;
  my $random_token = "";
  $random_token .= $chars[rand @chars] for 1..10;
  my $token_final = sha256_hex($random_token);

  database->quick_insert('api_users', { api_token => $token_final, email => $user_email, requests => 0 });

  send_email_to_user($user_email, $random_token);
}

sub send_email_to_user{
  my ($user_email, $token) = @_;

  email { to => "$user_email",
        subject => "Here is your token",
        message => "Your token is: $token .\nYou have $request_limit request coins a day in our platform where different functionalities have different cost.\nEnjoy!\nBest regards, SplineAPI owners." };

  return 1;
}
