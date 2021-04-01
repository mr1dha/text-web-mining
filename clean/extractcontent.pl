#!/usr/bin/perl
use strict;
use warnings;
use HTML::ExtractContent;
use File::Basename;
use utf8;
# get directory and initialize modules
my $directory = $ARGV[0] or die "directory belum diisi"; #example : ./data not ./data/
my @files = `find $directory/*.html`;
my $extractor = HTML::ExtractContent->new;
# Directory where clean data are stored, its better to set this in config file
my $PATHCLEAN = "./travel-mk";

my @count=(0,0);
my $category;
my $i = 1;
print "On process get data from $ARGV[0] ...\n";
foreach my $file(@files){ 
    
    my $fileout = "$PATHCLEAN/travel-$i.bersih.dat";

    # open file
    open OUT, "> $fileout" or die "Cannot Open File!!!";
    binmode(OUT, "encoding(UTF-8)");

    my $html = `cat $file`;
    $html =~ s/\^M//g;

    # get TITLE
    if($html =~ /<title.*?>(.*?)<\/title>/){
        my $title = $1;

        $title = clean_str($title);
        print OUT "<title>$title</title>\n";
    }

    $html =~ s/<figcaption.*?>(.|\n)?<\/figcaption>+//g;
    $html =~ s/<nav.*?>(.|\n)?<\/nav>+//g;
    $html =~ s/<strong.*?>(.*?)<\/strong>+//g;
    $html =~ s/<b.*?>(.*?)<\/b>+//g;
    
    # get BODY (Content)
    $extractor->extract($html);
    my $content = $extractor->as_text;
    $content = clean_str($content);
    split_content($content);

    # close file
    close OUT;
    $i++;
}

print "\nSuccess...\n";

# split content to top, middle, and bottom
sub split_content{
    my @contents = split /\. /,$_[0];
    my $length = @contents;
    my $part = int($length/3);
    my @sections=('','','');
    if($part != 0){
        my ($index , $iterate, $pattern) = (0 , 0, $length % 3);
        my $isIterate = 0 eq 0;
        foreach my $content (@contents){
            $sections[$index].=$content.". ";
            $iterate++;
            if($iterate % $part == 0){
                if($index + 1 <= $pattern && $isIterate){
                    $iterate--;
                    $isIterate = 1 eq 0;
                }else{
                    $index++;
                    $isIterate = 0 eq 0;
                }
            }
        }
        my @index=("top", "middle", "Bottom");
        my $i = 0;
        foreach my $section(@sections) {
            print OUT "<$index[$i]>$section</$index[$i]>\n";
            $i++;
        }
            
    }else{
        print OUT "<top>unknown</top>\n<middle>unknown</middle>\n<bottom>unknown</bottom>\n";
    }
}

# clean string using regex
sub clean_str {
    my $str = shift;
    $str =~ s/>//g;
    $str =~ s/&.*?;//g;
    $str =~ s/[\]\|\[\@\#\$\%\*\&\\\(\)\"]+//g;
    $str =~ s/-/ /g;
    $str =~ s/\n+//g;
    $str =~ s/\s+/ /g;
    $str =~ s/^\s+//g;
    $str =~ s/\s+$//g;
    $str =~ s/^$//g;
    return $str;
}
