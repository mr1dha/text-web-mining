#!/usr/bin/perl

for (my $threshold = 0.4; $threshold <=0.5; $threshold += 0.1) {

	print "\nTHRESHOLD = $threshold\n";
	#Membuat file kamus yang sudah dieliminasi
	open POSITIVE, "> otomotif_$threshold"."_final.txt" or die "can't open file :otomotif/otomotif_final.txt\n";
	open NEGATIVE, "> travel_$threshold"."_final.txt" or die "can't open file :travel/travel_final.txt\n";
	open DELETE, "> deleted_grams_$threshold"."_final.txt" or die "can't open file deleted_grams_final.txt";

	print"Created file kamus ...\n\n";

	for (my $gr = 1; $gr <= 3; $gr++) {

		my %dict_otomotif;
		my %dict_travel;

		#Memanggil file
		load_file(\%dict_otomotif, "otomotif", otomotif, $gr);
		load_file(\%dict_travel, "travel", travel, $gr);

		print"Called kamus $gr"."_gram ...\n";

		#Menghitung frekuensi terbanyak dari kamus otomotif
		my $index_otomotif = 0;
		foreach(keys %dict_otomotif) {
			if($dict_otomotif{$_} > $index_otomotif) {
				$index_otomotif = $dict_otomotif{$_};
			}
		}

		#Menghitung frekuensi terbanyak dari kamus travel
		my $index_travel = 0;
		foreach(keys %dict_travel) {
			if($dict_travel{$_} > $index_travel) {
				$index_travel = $dict_travel{$_};
			}
		}

		#Proses eliminasi kamus dengan threshold
		foreach(keys %dict_otomotif) {
			if(defined($dict_travel{$_})) {
				my $otomotif = $dict_otomotif{$_}/$index_otomotif;
				my $travel = $dict_travel{$_}/$index_travel;

				my $ratio;

				# Normalization value word X in Kamus A less than kamus B
				if ($otomotif < $travel) {
					$ratio = $otomotif/$travel;

					# ratio less than threshold
					if ($ratio <  $threshold) {
						delete $dict_otomotif{$_};
						print DELETE "otomotif,".$_."\n";
					} else {
						delete $dict_otomotif{$_};
						delete $dict_travel{$_};
						print DELETE "both,".$_."\n";
					}
				}

				# Normalization value word X in Kamus A greater than kamus B
				if($otomotif > $travel) {
					$ratio = $travel/$otomotif;
					
					# ratio less than threshold
					if ($ratio <  $threshold) {
						delete $dict_travel{$_};
						print DELETE "travel,".$_."\n";
					} else {
						delete $dict_otomotif{$_};
						delete $dict_travel{$_};
						print DELETE "both,".$_."\n";
					}
				}

				# Ratio each word is equal
				if($otomotif == $travel) {
					delete $dict_otomotif{$_};
					delete $dict_travel{$_};
					print DELETE "both,".$_."\n";
				}
			}
		}

		# loops to print the output separated by comma format
		foreach(keys %dict_otomotif) {
			my $positive = sprintf("%.6f", $dict_otomotif{$_}/$index_otomotif);
			print POSITIVE "$_, $dict_otomotif{$_}, $positive\n";
		}

		foreach(keys %dict_travel) {
			my $negative = sprintf("%.6f", $dict_travel{$_}/$index_travel);
			print NEGATIVE "$_, $dict_travel{$_}, $negative\n";
		}
		print "Eliminated kamus $gr"."gram ...\n\n";
	}

	#Close file
	close POSITIVE;
	close NEGATIVE;
	close DELETE;
	print "Closed File...\n";
}

#Subroutine to load file
sub load_file {
	my ($hashref,$dir,$file,$n) = @_;

	open IN, "< $dir/$n"."_grams_$file.txt" or die "Can't open file :  $dir/".$n."_grams_$file.txt\n";
	foreach(<IN>) {
		chomp;
		my @arr = split(",", $_);
		my $a = $arr[0];
		my $b = $arr[1];
		$$hashref{$a} = $b;
	}
	close IN;
}
