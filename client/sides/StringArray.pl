#!/usr/bin/perl

sub parseStringArray {
	my @parms = @_;

	my @values = split(',', $parms[0]);
	foreach my $val (@values) {
		$val =~ s/["| |']//g; # technically support for legacy code format
	}
	if(defined $parms[1]) {
		return @values[$parms[1]];
	}
	else {
		return @values;
	}
}

# received from database
$s = 'no, yes, yes, no, yes, yes, no, yes, no, yes, yes';
@arr = parseStringArray($s);

for($i = 0; $i < @arr.length; $i++) {
	if(@arr[$i] =~ /^yes$/) {
		print $i . " is yes!\n";
		print "Settings it to false!\n";
		
		@arr[$i] = "no";
		print "Success!\n\n";
	}
}

$scal = join(", ", @arr);
print $scal . "\n";