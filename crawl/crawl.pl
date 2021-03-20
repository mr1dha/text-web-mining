use strict;
use warnings;
use POSIX qw(strftime);
use feature 'state';
use WWW::Mechanize;

sub genDate{
    return my $date = strftime "$_[0]", localtime time()-($_[1]*24*60*60);
}

my $mech = WWW::Mechanize->new();
my @all_urls;
my %news_links;
my $total_kompas = 0;
my $url = "";

my $fileName = $ARGV[1] or die "\n%~ perl crawler.pl [jumlah page] [output file]\n";
open OUT, ">$fileName" or die "Tidak Bisa Membuat File!";

my $total_pages = int($ARGV[0]) or die "\n%~ perl crawler.pl [jumlah page] [output file]\n";

print "\nMemulai pendataan tautan.....\n";

    my $page;

    for ($page=1; $page<=$total_pages; $page++){
	print "Memulai crawling kategori edukasi pada page-".$page."\n";

        #url ini adalah pola url dari situs kompas
        $url = "https://indeks.kompas.com/?site=travel&page=".$page;
        
        $mech->get($url);
        @all_urls = $mech->links();
        
        foreach my $link (@all_urls){
            my $url = $link->url;

                #jika url mengandung substring "/read/" dan tidak mengandung "video" dan belum di-hash, maka hash
                if ($url=~"/travel.kompas.com\/read/" && $url !~ "/video/" && !exists $news_links{$link->url}){

                    if ($url =~"kompas.com" && $total_kompas<=10000){
                      $news_links{$url} = 1;
                      $total_kompas++;
                    }
                }
        } #akhir looping untuk array all_urls
    } #akhir looping halaman

print "Berhasil mendapatkan ". ($total_kompas) ."tautan.\nMemulai pengunduhan....";

foreach (sort keys (%news_links)) {
    print OUT "$_\n";
}
print "\nproses selesai!\nURL yang disimpan ". ($total_kompas) ." \n\n";
close OUT;

