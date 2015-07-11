package ws;
package Spline;

use Dancer2 ':syntax';
use utf8;
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

get '/tokeninfo' => sub {
  my %input_params = params;
  return to_json ($indexmap{$input_params{token}});
};

get '/usage' => sub {
  template 'usage' => {
  };
};

get '/register' => sub {
  template 'sign_in' => {
  };
};

post '/sign_in' => sub {
  my %input_params = params;
  my $user_email = $input_params{email};

  if (!$input_params{'g-recaptcha-response'} eq ''){
    add_user($user_email, has_user($user_email));
    redirect '/';
  }

  redirect '/register';
};

get '/userinfo' => sub {
  my %input_params = params;
  $input_params{history} = 0 if(!$input_params{history});
  my %user_hash = ();

  if($input_params{api_token}){
    $user_hash{coins} = get_user_coins($input_params{api_token});
    if($input_params{history}==1){
      $user_hash{history} = get_user_history($input_params{api_token});
    }
  }

  template 'user' => {
    user_hash => \%user_hash
  };
};

post '/userinfo' => sub {
  my %input_params = params;
  $input_params{history} = 0 if(!$input_params{history});
  my %user_hash = ();

  if(%input_params){
    $user_hash{coins} = get_user_coins($input_params{api_token});
    if($input_params{history}==1){
      $user_hash{history} = get_user_history($input_params{api_token});
    }
  }

  return to_json(\%user_hash);

};

#any ['get', 'post'] => '/*' => sub {
post '/*' => sub {
  my ($path) = splat; 
  my @error = ();
  my $result = to_json(\@error);
  my %input_params = params;
  my $uploads = request->uploads();
  for my $file (keys %{$uploads}){
    my $upload = $uploads->{$file};
    $upload->copy_to('data/files');
    $_ = $upload->tempname;
    s/\/tmp\///;
    $input_params{$file} = 'data/files/'.$_;
  }
  my $val = $routemap{$path}{param_function}->(\%input_params);
  if ($val==1){
    my $cost = $routemap{$path}{cost_function}->(\%input_params);
    if(do_request($input_params{api_token}, $cost, $path) == 1){
      $result = $routemap{$path}{main_function}->(\%input_params);
    }
  }
  return $result;
};

true;

# AUXILIAR FUNCTIONS

sub do_request{
  my ($api_token, $cost, $path) = @_;
  my $encryptoken = sha256_hex($api_token);

  my $row = database->quick_select('api_users', { api_token => $encryptoken });
  return 0 if(!$row->{email});
  my $old_requests = $row->{requests};
  my $request_limit = $row->{request_limit};

  if($request_limit-($old_requests+$cost) >= 0){
    my $new_requests = $old_requests + $cost;
    my $localtime = localtime();
    database->quick_update('api_users', { email => $row->{email} }, { requests => $new_requests });
    database->quick_insert('api_history', { api_token => $encryptoken, request => $path, cost => $cost, date => $localtime });
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
  my ($user_email, $has_user) = @_;
  my @chars = ("A".."Z", "a".."z");
  my $string;
  my $random_token = "";
  $random_token .= $chars[rand @chars] for 1..10;
  my $token_final = sha256_hex($random_token);

  if($has_user==0){
    database->quick_insert('api_users', { api_token => $token_final, email => $user_email, requests => 0 });
    send_email_to_add_user($user_email, $random_token);
  }
  if($has_user==1){
    database->quick_update('api_users', { email => $user_email }, { api_token => $token_final });
    my $row = database->quick_select('api_users', { email => $user_email });
    send_email_to_change_user($user_email, $random_token, $row->{request_limit}-$row->{requests});
  }
}

sub send_email_to_add_user{
  my ($user_email, $token) = @_;

  email { to => "$user_email",
        subject => "Here is your token",
        message => "Your token is: $token .\nYou initially have 1000 request coins a day in our platform where different functionalities have different cost.\nEnjoy!\nBest regards, SplineAPI owners." };

  return 1;
}

sub send_email_to_change_user{
  my ($user_email, $token, $requests) = @_;

  email { to => "$user_email",
        subject => "Here is your new token",
        message => "Your new token is: $token .\nYou still have $requests request coins today in our platform where different functionalities have different cost.\nBest regards, SplineAPI owners." };

  return 1;
}

sub get_user_coins{
  my ($api_token) = @_;
  my $encryptoken = sha256_hex($api_token);

  my $row = database->quick_select('api_users', { api_token => $encryptoken });
  return ($row->{request_limit}-$row->{requests});
}

sub get_user_history{
  my ($api_token) = @_;
  my $encryptoken = sha256_hex($api_token);

  my @rows = database->quick_select('api_history', { api_token => $encryptoken }, {columns => [qw(request cost date)]});
  return \@rows;
}
