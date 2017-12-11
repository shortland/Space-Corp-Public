package Spacecorp::ResourceTransaction;

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use JSON;
use Path::Tiny;

use Spacecorp::Regex qw(isInt);

use Exporter qw(import);
#getAll gets all the resources and updates them all too
#getUsersResAmt gets only 1 res type. (it also updates it..)
#changeResAmt adds or subtracts ,,,$amt of ,,$res, from users account
our @EXPORT_OK = qw(getAll getUsersResAmt changeResAmt);
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

# IT was ASSUMED THAT $AMT IS NEGATIVE INT IF THIS FUNCTION IS BEING CALLED.
# same purpose but uses getUsersRestAmt instead of its own foreach and key/value checking system.
#retuns FALSE, IF YOU HAVE ENOUGH
#returns TRUE/NUMBER, if you dont. the number it returns is the amount u need. (difference)
sub hasEnough {
    my ($idn, $DBH, $res, $amt) = @_;
    my $myAmt = getUsersResAmt($idn, $DBH, $res);
    if (($myAmt - substr($amt, 1)) < 0) {
        return ($myAmt - substr($amt, 1));
    }
    else {
        return 0;
    }
}

# get amount of $res that the user has.
sub getUsersResAmt {
    my ($idn, $DBH, $res) = @_;
    # updates resources so lets run this
    getAll($idn, $DBH);
    my $sth = $DBH->prepare("SELECT resources FROM userResources WHERE IDN = ?");
    $sth->execute($idn) or return 0;
    my $resCol = decode_json $sth->fetchrow_hashref()->{resources};
    my $hasAmt;
    foreach my $resource (@{$resCol->{resources}}) {
        if ((keys $resource)[0] =~ /^$res$/) {
            $hasAmt = (values $resource)[0];
        }
    }
    return $hasAmt;
}

# doesn't check for anything, assumes the user has enough and etc.
# adds or subtracts depends on whether $amt is pos or neg
sub updateResAmt {
    my ($idn, $DBH, $res, $amt) = @_;
    my $resData = decode_json getAll($idn, $DBH);
    foreach my $resource (@{$resData->{resources}}) {
        if ((keys $resource)[0] =~ /^$res$/) {
            # ie: if $amt is negative. += $amt => +-= $amt => -= |$amt|
            $resource->{(keys $resource)[0]} += $amt; # works for pos and negative.
        }
    }
    my $sth = $DBH->prepare("UPDATE userResources SET resources = ? WHERE IDN = ?");
    $sth->execute(encode_json $resData, $idn) or return 0;
    return $resData;
}

sub changeResAmt {
    my ($idn, $DBH, $res, $amt) = @_;
    #check to see if amt is a number. (integer preferably)
    if(!isInt($amt)) {
        return encode_json {error => JSON::true, response => $amt . " isn't an int"};
        exit;
    }
    #check to see if we have enough of the resource before subtracting it from our bal.
    if ($amt < 0) {
        #only call this function if $amt is negative.
        if (hasEnough($idn, $DBH, $res, $amt)) {
            return encode_json {error => JSON::true, response => "You need " . hasEnough($idn, $DBH, $res, $amt) =~ s/-//r . " more"};#/
            exit;
        }
        # we have enough of the resource & want to take $amt away from current bal.
        return encode_json updateResAmt($idn, $DBH, $res, $amt);
    }
    else {
        # we are adding a resource.
        return encode_json  updateResAmt($idn, $DBH, $res, $amt);
    }
}

# gets all resources, but before returning them, updates them to currentTimestamp values
# $resC, $diff are optional. if not supplied - the function will simply return current resC amounts
# if supplied resC, and supplied $diff, 
# then resources resC will add/subtract $diff from the current amount of resC.
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
            else {
                # not a producable resource, so `gems` would fall into this category
                # not sure if I'd want to do anything here, but just for now ...
            }
        }
    }
    updateResT($idn, $nowTime, $DBH);
    return $newJson; # how to parse as client javscript...rip
}

1;