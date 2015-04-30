use DBI;
use strict;

my $driver   = "SQLite"; 
my $database = "spline.sqlite";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;


my $stmt = qq(UPDATE api_users SET requests = 0;);
my $rv = $dbh->do($stmt);
if($rv < 0){
   print $DBI::errstr;
}
$dbh->disconnect();

## fazer cronjob para este script