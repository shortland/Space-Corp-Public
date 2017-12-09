#!/usr/bin/perl

use warnings;

use Plack::Middleware::CrossOrigin;
use CGI::Carp qw( fatalsToBrowser );
use CGI::Cookie;
use CGI;
use DBI;
use JSON;
use File::Slurp;

sub DBstringArray {
    my @parms = @_;
    my @values = split(',', @parms[0]);
    foreach my $val (@values) {
        $val =~ s/["| |']//g;
    }
    return @values[@parms[1]];
}

sub isUpgrading {
    my @parms = @_;
    my @values = split(',', $parms[0]);
    foreach my $val (@values) {
        $val =~ s/["| |']//g;
    }

    if(defined $parms[2]) {
        @values[$parms[1]] = $parms[2];
        return join(", ", @values);
    }
    elsif(defined $parms[1]) {
        return @values[$parms[1]];
    }
    else {
        return @values;
    }
}

sub nameToPosition {
    my @parms = @_;
    my @arr;
    my $i;
    # USAGE
    # nameToPosition(name, type); 
    # => type: 'building' name, 'resource' name, 
    if(@parms[1] =~ /^building$/) {
        @arr = ("metal", "crystal", "gas", "lab", "cc", "shipyard", "corphq", "globalmarket", "stockmarket", "radar", "itemmender");
    }
    elsif(@parms[1] =~ /^resource$/) {
        @arr = ("cash, metal, crystal, gas, gems");
    }

    for($i = 0; $i < (scalar @arr); $i++) {
        if(@parms[0] =~ /^@arr[$i]$/) {
            return $i;
            last;
        }
    }
}

BEGIN {
    $DB_SQL_username = "";
    $DB_SQL_password = "";

    $q = new CGI;
    $method = $q->param('method');

    %cookies = CGI::Cookie->fetch;

    if(!defined $cookies{'u_cookie'} || !defined $cookies{'p_cookie'}) {
        print $q->header(-Location=>'login.pl');
        exit;
    }
    else {
        print "Content-Type: text/html\n\n";
        $got_u_cookie = $cookies{'u_cookie'}->value;
        $got_p_cookie = $cookies{'p_cookie'}->value;
        $got_u_cookie =~ s/'//g;
        $got_u_cookie =~ s/'//g;

        my $dbh_random123164 = DBI->connect("DBI:mysql:database=spacecorp;host=localhost", "$DB_SQL_username", "$DB_SQL_password", {'RaiseError' => 1});

        my $sth_random123164 = $dbh_random123164->prepare("SELECT system_name, system_x, system_y, u_cookie, p_cookie, username, last_income_update, level, power, building_level_data, upgrade_status_data, upgrade_time_data, current_resource_data, current_income_data FROM users WHERE u_cookie = ? AND p_cookie = ?");
        $sth_random123164->execute($got_u_cookie, $got_p_cookie) or die "Couldn't execute statement: $DBI::errstr; stopped";
        
        while(my($system_name, $system_x, $system_y, $u_cookie, $p_cookie, $username, $last_income_update, $level, $power, $buildingLevelData, $upgradeStatusData, $upgradeTimeData, $currentResourceData, $currentIncomeData) = $sth_random123164->fetchrow_array()) {
            #print $cash_balance;

            $real_username = $username;
            $real_email = $email;
            $real_access = $user_valid;

            $cTime = time; # dont remove this, 
            $elapsedTime = $cTime - $last_income_update;

            $cash_persec = ${\DBstringArray($currentIncomeData, 0)} / 3600; 
            $cash_persec_totals = ($cash_persec * $elapsedTime);
            $newCashBal = ${\DBstringArray($currentResourceData, 0)} + $cash_persec_totals;

            $metal_persec = ${\DBstringArray($currentIncomeData, 1)} / 3600;
            $metal_persec_totals = ($metal_persec * $elapsedTime);
            $newMetalBal = ${\DBstringArray($currentResourceData, 1)} + $metal_persec_totals;

            $crystal_persec = ${\DBstringArray($currentIncomeData, 2)} / 3600;
            $crystal_persec_totals = ($crystal_persec * $elapsedTime);
            $newCrystalBal = ${\DBstringArray($currentResourceData, 2)} + $crystal_persec_totals;

            $gas_persec = ${\DBstringArray($currentIncomeData, 3)} / 3600;
            $gas_persec_totals = ($gas_persec * $elapsedTime);
            $newGasBal = ${\DBstringArray($currentResourceData, 3)} + $gas_persec_totals;
            
            ## Okay, so this technically works, but this means that the client current resources shouldn't be updated every 1 second
            ## Otherwise the client says they have more money than the server thinks they have.
            ## Stick to 5< second total refresh
            ## I guess 6 seconds will suffice
            ## need to alter this client sided...
                #print $cash_persec_totals.">>\n";
                #print $metal_persec_totals.">>\n";
                #print $gas_persec_totals.">>\n";
                #print $crystal_persec_totals.">>\n";
            if($cash_persec_totals >= 1 && $metal_persec_totals >= 1 && $crystal_persec_totals >= 1 && $gas_persec_totals >= 1) {
                ## go on with updating values
                $lastIncomeUpdate = $cTime;
            }
            else {
                $lastIncomeUpdate = $last_income_update;
                ## force all balances to remain the same, since at least 1 of them isn't above +1
                $newCashBal = ${\DBstringArray($currentResourceData, 0)}; 
                $newMetalBal = ${\DBstringArray($currentResourceData, 1)}; 
                $newCrystalBal = ${\DBstringArray($currentResourceData, 2)}; 
                $newGasBal = ${\DBstringArray($currentResourceData, 3)}; 
            }

            # goes through upgrade status list 
            # upgrade a building if time has elapsed etc...
            for($i = 0; $i < isUpgrading($upgradeStatusData).length; $i++) {
                if(isUpgrading($upgradeStatusData, $i) =~ /^yes$/) {
                    if((isUpgrading($upgradeTimeData, $i) - time) <= 0) {

                        #print "it's done! " . $i . "\n\n";
                        ##  upgrade status to "no"
                        # shares same index
                        @statusArray = isUpgrading($upgradeStatusData);
                        @statusArray[$i] = "no";
                        $upgradeStatusData = join(", ", @statusArray);

                        ##  upgrade time to 0
                        # shares same index
                        @timeArray = isUpgrading($upgradeTimeData);
                        @timeArray[$i] = "0";
                        $upgradeTimeData = join(", ", @timeArray);

                        ##  updates current mine_level+1
                        # shares same index
                        @buildingLevelArray = isUpgrading($buildingLevelData);
                        @buildingLevelArray[$i]++;
                        $buildingLevelData = join(", ", @buildingLevelArray);

                        ## update income too
                        # DOES NOT share same index, must use a case-by-case scenario
                        @incomesArray = isUpgrading($currentIncomeData);
                        #   metal, crystal, gas, ___, cc (cash),....
                        my @conversionTable = ("1", "2", "3", "", "0");
                        #print "current income is: " . @incomesArray[@conversionTable[$i]] . "\n";
                        $levelIncomesChart = decode_json(read_file("../structures/building_data/mines_default.json"));
                        #print "upgraded income is: " . $levelIncomesChart->{'building_data'}{$i}{'levels'}[--@buildingLevelArray[$i]]{'income'} . "\n";
                        @incomesArray[@conversionTable[$i]] = $levelIncomesChart->{'building_data'}{$i}{'levels'}[--@buildingLevelArray[$i]]{'income'};
                        $currentIncomeData = join(", ", @incomesArray);
                        #print $newIncomesData;
                        my $sth = $dbh_random123164->prepare("UPDATE users SET `upgrade_status_data` = '$upgradeStatusData', `upgrade_time_data` = '$upgradeTimeData', `building_level_data` = '$buildingLevelData', `current_income_data` = '$currentIncomeData' WHERE `u_cookie` = ? AND `p_cookie` = ?");
                        $sth->execute($u_cookie, $p_cookie) or die "Couldn't execute statement: $DBI::errstr; stopped";
                    }
                }
            }

            ## we've updated any necessary building levels
            ## now we need to update cash if necessary
            @currentResources = isUpgrading($currentResourceData);
            # for($j = 0; $j < isUpgrading($currentIncomeData).length; $j++) {
            #     @currentResources[$j] = 
            # }
            @currentResources[0] = $newCashBal;
            @currentResources[1] = $newMetalBal;
            @currentResources[2] = $newCrystalBal;
            @currentResources[3] = $newGasBal;
            $newResourceData = join(", ", @currentResources);

            my $sth_random122213 = $dbh_random123164->prepare("UPDATE users SET `current_resource_data`= ?, `last_income_update` = ?, `last_ip` = ?, `last_ua` = ?, `last_logged` = ? WHERE `u_cookie` = ? AND `p_cookie` = ?");
            $sth_random122213->execute($newResourceData, $lastIncomeUpdate, $ENV{REMOTE_ADDR}, $ENV{HTTP_USER_AGENT}, $cTime, $u_cookie, $p_cookie) or die "Couldn't execute statement: $DBI::errstr; stopped";


            if($method =~ /^(login_A)$/) {
                $jsonObject = {
                    nowtime => time,
                    user_data => {
                        username => $real_username,
                        level => $level, 
                        power => $power, 
                        corporation => "-", 
                    },
                    planet_data => {
                        system_name => $system_name, 
                        system_x => $system_x, 
                        system_y => $system_y,
                        index => 0,
                    },
                    building_level_data => {
                        metal => ${\DBstringArray($buildingLevelData, 0)}, 
                        crystal => ${\DBstringArray($buildingLevelData, 1)}, 
                        gas => ${\DBstringArray($buildingLevelData, 2)}, 
                        cc => ${\DBstringArray($buildingLevelData, 4)}, 
                        lab => ${\DBstringArray($buildingLevelData, 3)}, 
                        shipyard => ${\DBstringArray($buildingLevelData, 5)}, 
                        corphq => ${\DBstringArray($buildingLevelData, 6)}, 
                        globalmarket => ${\DBstringArray($buildingLevelData, 7)}, 
                        stockmarket => ${\DBstringArray($buildingLevelData, 8)}, 
                        radar => ${\DBstringArray($buildingLevelData, 9)}, 
                        itemmender => ${\DBstringArray($buildingLevelData, 10)},
                    },
                    upgrade_status_data => {
                        metal => ${\DBstringArray($upgradeStatusData, 0)}, 
                        crystal => ${\DBstringArray($upgradeStatusData, 1)}, 
                        gas => ${\DBstringArray($upgradeStatusData, 2)}, 
                        cc => ${\DBstringArray($upgradeStatusData, 4)}, 
                        lab => ${\DBstringArray($upgradeStatusData, 3)}, 
                        shipyard => ${\DBstringArray($upgradeStatusData, 5)}, 
                        corphq => ${\DBstringArray($upgradeStatusData, 6)}, 
                        globalmarket => ${\DBstringArray($upgradeStatusData, 7)}, 
                        stockmarket => ${\DBstringArray($upgradeStatusData, 8)}, 
                        radar => ${\DBstringArray($upgradeStatusData, 9)}, 
                        itemmender => ${\DBstringArray($upgradeStatusData, 10)},
                    },
                    upgrade_time_data => {
                        metal => ${\DBstringArray($upgradeTimeData, 0)}, 
                        crystal => ${\DBstringArray($upgradeTimeData, 1)}, 
                        gas => ${\DBstringArray($upgradeTimeData, 2)}, 
                        cc => ${\DBstringArray($upgradeTimeData, 4)}, 
                        lab => ${\DBstringArray($upgradeTimeData, 3)}, 
                        shipyard => ${\DBstringArray($upgradeTimeData, 5)}, 
                        corphq => ${\DBstringArray($upgradeTimeData, 6)}, 
                        globalmarket => ${\DBstringArray($upgradeTimeData, 7)}, 
                        stockmarket => ${\DBstringArray($upgradeTimeData, 8)}, 
                        radar => ${\DBstringArray($upgradeTimeData, 9)}, 
                        itemmender => ${\DBstringArray($upgradeTimeData, 10)},
                    },
                    current_resource_data => {
                        cash => ${\DBstringArray($currentResourceData, 0)},
                        metal => ${\DBstringArray($currentResourceData, 1)},
                        crystal => ${\DBstringArray($currentResourceData, 2)},
                        gas => ${\DBstringArray($currentResourceData, 3)},
                        gems => ${\DBstringArray($currentResourceData, 4)},
                    },
                    current_income_data => {
                        cash => ${\DBstringArray($currentIncomeData, 0)},
                        metal => ${\DBstringArray($currentIncomeData, 1)},
                        crystal => ${\DBstringArray($currentIncomeData, 2)},
                        gas => ${\DBstringArray($currentIncomeData, 3)},
                        lastUpdate => $last_income_update, 
                    },
                };
                $json = JSON->new->allow_nonref->allow_singlequote;
                $jsonObject = $json->encode($jsonObject);#$json->pretty->encode($jsonObject);
                #$jsonObject =~ s/"/'/g;
                print "localStorage.setItem('accountNumber1', JSON.stringify($jsonObject));";
            }
            $valida = "ok";

        }
        $dbh_random123164->disconnect();

        if($valida !~ "ok")
        {
            print $q->header(-Location=>'login.pl');
        }
        if(!defined $valida)
        {
            print $q->header(-Location=>'login.pl');
        }
    }
}
open(STDERR, ">&STDOUT");


1;