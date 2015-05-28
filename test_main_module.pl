use Spline::Services;
use Data::Dumper;

my %hash = ( 
    file => 'Uma frase qualquer que funcione.',
    api_token => 'MAIlGopQUt',
 );

my $result = new_test(%hash); ##route

print Dumper($result);