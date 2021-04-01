#!/usr/bin/perl

# two-grams.pl 
# Digunakan untuk membangkitkan kamus 2-gram
#
# Taufik Fuadi Abidin
# Mei 2011


use lib '../lib';
use Lingua::EN::Bigram;
use strict;

#my @files = `find ../clean/travel-mk/*.bersih.dat`;
 my @files = `find ../clean/otomotif-mk/*.bersih.dat`;
#open TOFILE, "> ./travel-mk/3_grams_travel.txt" or die "Cannot Open File!!!";
 open TOFILE, "> otomotif-mk/3_grams_otomotif.txt" or die "Cannot Open File!!!";
my $counter = 1;
my %stopwords;

load_stopwords(\%stopwords);
foreach my $file(@files) {
print "total : $counter\n";
open F, $file or die "Can't open input: $!\n";
my $text = do { local $/; <F> };

#my $text = '';
#while(<F>){
#  $text .= $_;
#}

close F;


# build n-grams
my $ngrams = Lingua::EN::Bigram->new;
$ngrams->text( $text );
my @threegram = $ngrams->ngram( 3 );

# get bi-gram counts
my $three_count = $ngrams->ngram_count( \@threegram);

my $index = 0;


#print "##Bi-grams (T-Score, count, bi-gram)\n";
#foreach my $three ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {
foreach my $three (keys %$three_count ) {

	# get the tokens of the three
	my ( $first_token, $second_token, $third_token ) = split / /, $three;
	
	# skip stopwords and punctuation
	next if ( $stopwords{ $first_token } );
	next if ( $first_token =~ /[,.?!:;()\-]/ );
	next if ( $stopwords{ $second_token } );
	next if ( $second_token =~ /[,.?!:;()\-]/ );
	next if ( $stopwords{ $third_token } );
	next if ( $third_token =~ /[,.?!:;()\-]/ );
	
	$index++;

	#last if ( $index > 10 );

	# output
	#print sprintf("%6.3f", $$tscore{ $three }) . "\t"           . 
	#      "$$three_count{ $three }\t"     . 
	#      "$three\t\n";

	# print TOFILE "$$three_count{ $three }\t$three\n";
	print TOFILE "$three,$$three_count{ $three }\n";

}
$counter++;
}
sub load_stopwords 
{
  my $hashref = shift;
  open IN, "< stopwords.txt" or die "Cannot Open File!!!";
  while (<IN>)
  {
    chomp;
    if(!defined $$hashref{$_})
    {
       $$hashref{$_} = 1;
    }
  }  
}

  

