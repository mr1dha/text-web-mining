#!/usr/bin/perl

# two-grams.pl 
# Digunakan untuk membangkitkan kamus 2-gram
#
# Taufik Fuadi Abidin
# Mei 2011


use lib '../lib';
use Lingua::EN::Bigram;
use strict;

my @files = `find ../clean/travel-mk/*.bersih.dat`;
# my @files = `find ../clean/otomotif-mk/*.bersih.dat`;
open TOFILE, "> travel-mk/1_grams_travel.txt" or die "Cannot Open File!!!";
# open TOFILE, "> ./kamus/otomotif-mk/1_grams_otomotif.txt" or die "Cannot Open File!!!";
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
my @onegram = $ngrams->ngram( 1 );

# get bi-gram counts
my $onegram_count = $ngrams->ngram_count( \@onegram );

my $index = 0;


#print "##Bi-grams (T-Score, count, bi-gram)\n";
#foreach my $onegram ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {
foreach my $onegram (keys %$onegram_count ) {

	
	# skip stopwords and punctuation
	next if ( $stopwords{ $onegram } );
	next if ( $onegram =~ /[,.?!:;()\-]/ );
	
	$index++;

	#last if ( $index > 10 );

	# output
	#print sprintf("%6.3f", $$tscore{ $onegram }) . "\t"           . 
	#      "$$bigram_count{ $bigram }\t"     . 
	#      "$bigram\t\n";

	# print TOFILE "$$onegram_count{ $onegram }\t$onegram\n";
	print TOFILE "$onegram,$$onegram_count{ $onegram }\n";

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

  

