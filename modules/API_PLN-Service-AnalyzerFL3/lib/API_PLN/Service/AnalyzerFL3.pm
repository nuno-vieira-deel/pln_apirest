package API_PLN::Service::AnalyzerFL3;

use 5.018002;
use strict;
use warnings;
use JSON;
use URI::Escape;
use FL3 'pt';
use Lingua::FreeLing3::Sentence;
use Lingua::FreeLing3::Utils qw/word_analysis/;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

my $fl3_morph_pt = Lingua::FreeLing3::MorphAnalyzer->new('pt',
    ProbabilityAssignment  => 0, QuantitiesDetection    => 0,
    MultiwordsDetection    => 0, NumbersDetection       => 0,
    DatesDetection         => 0, NERecognition          => 0,
  );


my %index_info = (
  hash_token => 'fl3_analyzer',
  parameters => {
    text => {
      description => 'The text to be analyzed',
      required => 1,
    },
    ner => {
      description => 'Named-entity recognition',
      required => 0,
    },
  },
  subtitle => 'Subtitulo de fl3_analyzer',
  description => 'Descricao de fl3_analyzer',
  example => {
    input => 'O input.',
    output => '[{"lemma":"o","pos":"DA0MS0","word":"O"},{"lemma":"input","pos":"NCMS000","word":"input"},{"pos":"Fp","lemma":".","word":"."}]',
  },
);

sub get_token {
  return $index_info{hash_token};
}

sub get_info {
  return \%index_info;
}

sub param_function {
#  return sub {
    my ($input_params) = @_;
    my $flag = 1;
    for my $param (keys %{$index_info{parameters}}){
      if ($index_info{parameters}{$param}{required} == 1){
        $flag = 0 if (!exists($input_params->{$param}));
      }
    }
    return $flag;
 # }
}

sub main_function {
	#return sub {
		my ($input_params) = @_;
		my $text = $input_params->{text};
		my $ner = 0;
		$ner = $input_params->{ner} if exists $input_params->{ner};
		my %options = ( lang => 'pt', ner => $ner );
		my $result = _fl3_analyzer($text, %options);
		return encode_json $result;
	#}
}


sub _fl3_analyzer {
  my ($text, %options) = @_;
  return unless $text;

  my $morph = Lingua::FreeLing3::MorphAnalyzer->new($options{lang},
      NERecognition => $options{ner},
    );

  my $tokens = tokenizer->tokenize($text);
  my $sentences = splitter->split($tokens);
  $sentences = $morph->analyze($sentences);
  $sentences = hmm->analyze($sentences);

  my $result;
  foreach (@$sentences) {
    my @words = $_->words;
    foreach my $w (@words) {
      push @$result, {word=>$w->form, pos=>$w->tag, lemma=>$w->lemma};
    }
  }

  return $result;
}

1;
__END__
