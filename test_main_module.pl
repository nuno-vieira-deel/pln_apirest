use Spline::Services;
use Data::Dumper;

my %hash = ( 
    text => 'Uma frase qualquer que funcione.',
    api_token => 'KajMZtKtTt',
 );

my $result = fl3_analyzer(%hash);

print Dumper($result);