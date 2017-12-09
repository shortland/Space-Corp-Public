package Spacecorp::ResourceTransaction;

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use JSON;
use Path::Tiny;

use Exporter qw(import);
use Data::Dumper;
our @EXPORT_OK = qw(updateAll getAll setMetal getMetal);
our %producedByName = (cash => "Command_Center", metal => "Metal_Mine", crystal => "Crystal_Mine", gas => "Gas_Mine");

sub getAmtHr {
    my ($producerName, $producerLevel) = @_;
    my $syncData = decode_json path("../sync/bData.json")->slurp;
    my $amtHr = $syncData->{building_data}{$producerName}{levels}[$producerLevel-1];
    return $amtHr->{income};
}

sub getBuildLevelFromName {
    my ($buildName, $data) = @_;
    for (my $i = 0; $i < scalar @{$data->{building_levels}}; $i++) {
        my %hash = %{$data->{building_levels}[$i]};
        keys %hash;
        while(my($k, $v) = each %hash) {
            if ($k =~ /^$buildName$/) {
                return $v;
            }
        }
    }
}

sub calcNewRes {
    my ($thenRes, $thenTime, $nowTime, $amtHr) = @_;
    my $converted = ($nowTime - $thenTime) * ($amtHr / 3600);
    my $nowRes = $thenRes + $converted; 
    return $nowRes;
}

sub updateRes {
    my ($idn, $t, $resType, $resNew, $jsonData, $DBH) = @_;
    my @actualArray = @{$jsonData->{resources}};
    for (my $i = 0; $i < scalar @{$jsonData->{resources}}; $i++) {
        my %hash = %{$jsonData->{resources}[$i]};
        keys %hash;
        while(my($k, $v) = each %hash) {
            if ($k =~ /^$resType$/) {
                for (my $i = 0; $i < scalar @actualArray; $i++) {
                    my %singleHash = %{$actualArray[$i]};
                    my $keyName = (keys %singleHash)[0];
                    if ($keyName =~ /^$resType$/) {
                        $actualArray[$i]{$keyName} = $resNew;
                        last;
                    }
                }
                last;
            }
        }
    }
    my %tempHash = ("resources" => \@actualArray);
    my $newJson = encode_json \%tempHash;
    my $sth = $DBH->prepare("UPDATE userResources SET resources = ? WHERE IDN = ?");
    $sth->execute($newJson, $idn) or return 0;
    return $newJson;
}

sub updateResT {
    my ($idn, $t, $DBH) = @_;
    my $sth = $DBH->prepare("UPDATE userResources SET resourcesTime = ? WHERE IDN = ?");
    $sth->execute($t, $idn) or return 0;
    return 1;
}

# gets all resources, but before returning them, updates them to currentTimestamp values
sub getAll {
    my ($idn, $DBH) = @_;
    my $nowTime = time();
    my $sth = $DBH->prepare("SELECT resources, resourcesTime, buildingLevels FROM userResources WHERE IDN = ?");
    $sth->execute($idn) or return 0;
    my $historicRes = $sth->fetchrow_hashref();
    my $resCol = decode_json $historicRes->{resources};
    my $resColT = $historicRes->{resourcesTime};
    my $bLevelCol = decode_json $historicRes->{buildingLevels};
    my $newJson;
    for (my $i = 0; $i < scalar @{$resCol->{resources}}; $i++) {
        my %hash = %{$resCol->{resources}[$i]};
        keys %hash;
        while(my($k, $v) = each %hash) {
            if (defined $producedByName{$k}) {
                my $buildLevel = getBuildLevelFromName($producedByName{$k}, $bLevelCol);
                my $amtHr = getAmtHr($producedByName{$k}, $buildLevel);
                my $resNew = calcNewRes($v, $resColT, $nowTime, $amtHr);
                $newJson = updateRes($idn, $nowTime, $k, $resNew, $resCol, $DBH);
            }
        }
    }
    updateResT($idn, $nowTime, $DBH);
    return $newJson; # how to parse as client javscript...rip
}

1;