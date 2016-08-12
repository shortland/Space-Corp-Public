#!/usr/bin/perl

use strict;
use warnings;

my $dir = 'rename_these/';

opendir(DIR, $dir) or die $!;

while (my $file = readdir(DIR))
{
    # ignores files beginning with a period
    next if ($file =~ m/^\./);

    `mv "$dir$file" $dir"removed_8_9_16_$file"`;
}

closedir(DIR);