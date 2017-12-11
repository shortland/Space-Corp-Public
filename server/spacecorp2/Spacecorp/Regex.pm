package Spacecorp::Regex;

use strict;
use warnings;

use Spacecorp::ErrorRecorder;
 
use Exporter qw(import);
 
our @EXPORT_OK = qw(isCharNum isPosInt isPosIntLeast2 isPosIntNotBin isCharNumSpecials isInt);

sub isPosIntNotBin {
	my ($n) = @_;
	if (!defined $n) {
		return 0;
	}
	elsif ($n =~ /^[0|1]$/) {
		return 0;
	}
	elsif ($n =~ /^\d+$/) {
		return 1;
	}
	else {
		return 0;
	}
}

sub isPosIntLeast2 {
	my ($n) = @_;
	if (!defined $n) {
		return 0;
	}
	elsif ($n =~ /^\d\d+$/) {
		return 1;
	}
	else {
		return 0;
	}
}

sub isPosInt {
	my ($n) = @_;
	if (!defined $n) {
		return 0;
	}
	elsif ($n =~ /^\d+$/) {
		return 1;
	}
	else {
		return 0;
	}
}
 
sub isCharNum {
	my ($n) = @_;
	if (!defined $n) {
		return 0;
	}
	elsif ($n =~ /^\w+$/) {
		return 1;
	}
	else {
		return 0;
	}
}
 
sub isCharNumSpecials {
	my ($n) = @_;
	if (!defined $n) {
		return 0;
	}
	elsif ($n =~ /^\w+$/) {
		return 1;
	}
	else {
		return 0;
	}
}

sub isInt {
	my ($n) = @_;
	if (!defined $n) {
		return 0;
	}
	elsif ($n =~ /^-?[1-9]\d*$/) {
		return 1;
	}
	else {
		return 0;
	}
}
 
1;