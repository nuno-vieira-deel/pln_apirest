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
use Digest::SHA qw(sha1 sha256);
use DBI;
our $VERSION = '0.1';

my $driver   = "SQLite"; 
my $database = "db/spline.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;

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

  add_user($user_email) if (has_user($user_email) == 0);

  template 'index' => {
    tools => \%indexmap
  };
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

sub has_user{
  my $user_email = shift;
  my $result = 0;
  my $stmt = qq(SELECT * from api_users where email = "$user_email";);
  my $sth = $dbh->prepare( $stmt );
  my $rv = $sth->execute() or die $DBI::errstr;
  if($rv < 0){
     print $DBI::errstr;
  }
  $result += 1 while(my @row = $sth->fetchrow_array());
  return $result;
}

sub add_user{
  my $user_email = shift;
  my @chars = ("A".."Z", "a".."z");
  my $string;
  my $random_token = "";
  $random_token .= $chars[rand @chars] for 1..10;
  my $token_final = sha256($random_token);

  my $stmt = qq(INSERT INTO api_users(api_token, email, requests) VALUES ("$token_final", "$user_email", 0));
  my $rv = $dbh->do($stmt) or die $DBI::errstr;
}
