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
my $total_viva = 0;
my $url = "";

my $fileName = $ARGV[1] or die "\nAnda tidak Memasukkan Nama File. Ulangi Input...\n";
open OUT, ">$fileName" or die "Tidak Bisa Membuat File!";

my $total_days = int($ARGV[0]) or die "\nAnda tidak menginput jumlah hari kebelakang yang ingin anda crawl\nUlangi Input...";

print "\nMemulai pendataan tautan.....\n";

for (my $i=0; $i<=$total_days; $i++){ #variabel $input harus dicasting ke int agar looping berjalan

    my $date = genDate("%Y-%m-%d", $i); 

    #melakukan operasi split terhadap string hasil dari
    #operasi genDate(). Setiap angka dipisahkan menurut tanda '-'
    (my $year, my $month, my $day) = split /-/, $date;
    print "Crawling data pada : $date\n";

    my $page;
	for (my $deep=1; $deep<=3; $deep++) {
        
	#url ini adalah pola url dari situs viva.co.id
        $url = "https://bola.kompas.com/search/$year-$month-$day/$deep";
        
        $mech->get($url);
        @all_urls = $mech->links();
        
        foreach my $link (@all_urls){
            my $url = $link->url;

                #jika url mengandung substring "/read/" dan belum di-hash, maka hash
                if ($url=~"www.kompas.com\/sports\/read/" && !exists $news_links{$link->url})
		{
                    if ($total_viva<=10000){
                      $news_links{$url} = 1;
                      $total_viva++;
                    }
                }
        } #akhir looping untuk array all_urls
    } 
} #akhir looping tanggal

print "Berhasil mendapatkan ". ($total_viva) ."tautan.\nMemulai pengunduhan....";

foreach (sort keys (%news_links)) {
    print OUT "$_\n";
}
print "\nproses selesai!\nURL yang disimpan ". ($total_viva) ." \n\n";
close OUT;

