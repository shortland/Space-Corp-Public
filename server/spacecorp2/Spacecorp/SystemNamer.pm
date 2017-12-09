package Spacecorp::SystemNamer;

use strict;
use warnings;
 
use Exporter qw(import);
 
our @EXPORT_OK = qw(random_system);
 
sub random_system {
	# all credit to http://fantasynamegenerators.com/planet_names.php
	# this is basically a perl ripoff version of their script

	my @nm1 = ("b", "c", "d", "f", "g", "h", "i", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z", "", "", "", "", "");
	my @nm2 = ("a", "e", "o", "u");
	my @nm3 = ("br", "cr", "dr", "fr", "gr", "pr", "str", "tr", "bl", "cl", "fl", "gl", "pl", "sl", "sc", "sk", "sm", "sn", "sp", "st", "sw", "ch", "sh", "th", "wh");
	my @nm4 = ("ae", "ai", "ao", "au", "a", "ay", "ea", "ei", "eo", "eu", "e", "ey", "ua", "ue", "ui", "uo", "u", "uy", "ia", "ie", "iu", "io", "iy", "oa", "oe", "ou", "oi", "o", "oy");
	my @nm5 = ("turn", "ter", "nus", "rus", "tania", "hiri", "hines", "gawa", "nides", "carro", "rilia", "stea", "lia", "lea", "ria", "nov", "phus", "mia", "nerth", "wei", "ruta", "tov", "zuno", "vis", "lara", "nia", "liv", "tera", "gantu", "yama", "tune", "ter", "nus", "cury", "bos", "pra", "thea", "nope", "tis", "clite");
	my @nm6 = ("una", "ion", "iea", "iri", "illes", "ides", "agua", "olla", "inda", "eshan", "oria", "ilia", "erth", "arth", "orth", "oth", "illon", "ichi", "ov", "arvis", "ara", "ars", "yke", "yria", "onoe", "ippe", "osie", "one", "ore", "ade", "adus", "urn", "ypso", "ora", "iuq", "orix", "apus", "ion", "eon", "eron", "ao", "omia");
	my @nm7 = ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
	my $br = "";

	my $nmsz1 = @nm1;
	my $nmsz2 = @nm2;
	my $nmsz3 = @nm3;
	my $nmsz4 = @nm4;
	my $nmsz5 = @nm5;
	my $nmsz6 = @nm6;
	my $nmsz7 = @nm7;

	my $i = int(rand(10)) + 1; # 1 to 10
	my $rnd;
	my $rnd2;
	my $rnd3;
	my $rnd4;
	my $rnd5;
	my $rnd6;
	my $names;
	if($i < 2) {
		$rnd = int(rand() * $nmsz1);
		$rnd2 = int(rand() * $nmsz2);
		$rnd3 = int(rand() * $nmsz3);
		$rnd4 = int(rand() * $nmsz4);
		$rnd5 = int(rand() * $nmsz5);
		$names = $nm1[$rnd] . $nm2[$rnd2] . $nm3[$rnd3] . $nm4[$rnd4] . $nm5[$rnd5];
	}
	if($i < 4) {
		$rnd = int(rand() * $nmsz1);
		$rnd2 = int(rand() * $nmsz2);
		$rnd3 = int(rand() * $nmsz3);
		$rnd4 = int(rand() * $nmsz6);
		$names = $nm1[$rnd] . $nm2[$rnd2] . $nm3[$rnd3] . $nm6[$rnd4];
	}
	if($i < 6) {
		$rnd = int(rand() * $nmsz1);
		$rnd4 = int(rand() * $nmsz4);
		$rnd5 = int(rand() * $nmsz5);
		$names = $nm1[$rnd] . $nm4[$rnd4] . $nm5[$rnd5];
	}
	if($i < 8) {
		$rnd = int(rand() * $nmsz1);
		$rnd2 = int(rand() * $nmsz2);
		$rnd3 = int(rand() * $nmsz3);
		$rnd4 = int(rand() * $nmsz2);
		$rnd5 = int(rand() * $nmsz5);
		$names = $nm3[$rnd3] . $nm2[$rnd2] . $nm1[$rnd] . $nm2[$rnd4] . $nm5[$rnd5];
	}
	else {
		$rnd = int(rand() * $nmsz3);
		$rnd2 = int(rand() * $nmsz6);
		$rnd3 = int(rand() * $nmsz7);
		$rnd4 = int(rand() * $nmsz7);
		$rnd5 = int(rand() * $nmsz7);
		$rnd6 = int(rand() * $nmsz7);
		$names = $nm3[$rnd] . $nm6[$rnd2] . " " . $nm7[$rnd3] . $nm7[$rnd4] . $nm7[$rnd5] . $nm7[$rnd6];
	}
	return ucfirst($names);
}
 
1;