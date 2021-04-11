use strict;
use warnings;
use Lingua::EN::Ngram;
use POSIX qw(ceil);


# build n-grams
my $ngrams = Lingua::EN::Ngram->new;

my ($PATH,$PATHDICT) = ("../clean","../kamus");
my $dirfile = $ARGV[0];
if(!$dirfile){
    print "Cara jalankan : $0 <directory file>\n"; #feature not feature/
}


my @dictionary = ("travel_0.5_final.txt","otomotif_0.5_final.txt");

print "Collecting  Dictionary ...\n";
my (%hashtravel,%hashotomotif);

foreach my $dict(@dictionary){
    my $dictfile = `cat $PATHDICT/$dict`;
    foreach my $line (split /\n/,$dictfile){
        chomp($line);
        next if($line =~ /^#|^$/ );
        my @formats = split /,/,$line;
        if(!exists($hashtravel{$formats[0]}) && $dict=~/travel/){
            $hashtravel{$formats[0]} = 1;
        }elsif(!exists($hashotomotif{$formats[0]}) && $dict=~/otomotif/){
            $hashotomotif{$formats[0]} = 1;
        }
    }
}


my $process=0;
foreach my $dir(("$PATH/travel-mk", "$PATH/otomotif-mk")){
    my @srcfile = split /\//,$dir;
    open OUT,"> $dirfile/feature_$srcfile[1].txt" or die "Can't open file...";
    open ARFF,"> $dirfile/feature_$srcfile[1].arff" or die "Can't open file...";
    print ARFF "\@relation feature_$srcfile[1]\n\n";
    foreach my $iterate (1 .. 36){
        print ARFF "\@attribute feature$iterate numeric\n";
    }
    print ARFF "\@attribute class {travel,otomotif}\n\n\@DATA\n";
    
    my @files = `find $dir/*.bersih.dat`;

    foreach my $file(@files){
        $process++;

        my $text = `cat $file`;

        $text =~ s/\n+//gs;

        if($file =~ /travel/){
            print OUT "travel ";
        }else{
            print OUT "otomotif ";
        }

        my @sections = (
            get_text($text,"title"),
            get_text($text,"top"),
            get_text($text,"middle"),
            get_text($text,"Bottom")
            );
        my @weight = (1,0.4,0.3,0.3);
        for (my $sec = 0 ; $sec < @sections; $sec++){
            for (my $dict = 0 ; $dict < @dictionary ; $dict++){
                foreach my $n (1 .. 3){
                    my $gram_score;
                    if($dict == 0){
                        $gram_score = count_section($sections[$sec], \%hashtravel, $n) * $weight[$sec];
                    }elsif($dict == 1){
                        $gram_score = count_section($sections[$sec], \%hashotomotif, $n)* $weight[$sec];
                    }

                    my $number = $sec * 6 + $dict * 3 + $n;
                    print ARFF sprintf("%.4f",$gram_score).",";
                    print OUT "$number:".sprintf("%.4f",$gram_score)." " ;
                }
            }
        }
        if($file =~ /travel/){
            print ARFF "travel\n";
        }else{
            print ARFF "otomotif\n";
        }
        print OUT "\n";
        if($process % 1000 == 0){
            print "\nDone : $process\n"
        }
    }
    close OUT;
    close ARFF;
}


# method for get text in xml file
sub get_text{
    my ($text,$regex) = @_;

    if($text =~ /<$regex>(.*?)<\/$regex>/){
        return $1;
    }
}

sub count_section{
    my($section, $hash, $n)=@_;  
    my $count=0;
    my $sect = clean_string($section);

    $ngrams->text($sect.".");
    my $txt = $ngrams->text;      
    my $grams = $ngrams->ngram($n);
    my $gramlen = 0;

    foreach my $gram ( sort { $$grams{ $b } <=> $$grams{ $a } } keys %$grams ){
        $gramlen++;
        chomp($gram);

        next if($gram =~ /^#/ || $gram =~ /^$/);

        if(defined $$hash{$gram}){
            $count++;
        }
    }

    if($count == 0){
        return 0;
    }
    else {
        return ($count/$gramlen);
    }
}


sub clean_string {
    my $file = shift;
    $file =~ s/<.*?>//g;
    $file =~ s/\s\w+=.*?>/ /g;
    $file =~ s/>//g;
    $file =~ s/&.*?;//g;
    $file =~ s/[\:\]\|\[\?\!\@\#\$\%\*\&\,\/\\\(\)\;]+//g;
    $file =~ s/-/ /g;
    $file =~ s/\s+/ /g;
    $file = lc($file);
    return $file;
}
