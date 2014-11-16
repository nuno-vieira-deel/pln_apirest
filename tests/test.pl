use API_PLN::Services;
use Data::Dumper;

my %hash = ( 
    text => 'Uma frase qualquer que funcione.'
 );

print Dumper(tokenizer(%hash));