#!/usr/bin/perl

# this is some really bad bad stuff here, it's just temporary until I redo the client
# make sure the same userName exists in both `user` and `users` table
# make sure the cookies are the same!!!!!!!!!
# make sure the client has cookies set already. if it doesnt... somethings gonna break probly
# copy cookies from `users` to `user`.

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
#use Plack::Middleware::CrossOrigin;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/';
use Spacecorp::LoggedInLegacy qw(attempt_login);
use Spacecorp::Auth qw(createDBH getUserIDN);
use Spacecorp::ResourceTransaction qw(getAll);

use JSON;

sub checkLogin {
    if (!defined attempt_login()) {
        print "You're not logged in.\n";
        exit;
    }
}

BEGIN {
    my $cgi = new CGI;
    print $cgi->header(-type => "text/plain", -status => "200 OK");
    # check for login, if not exit;
    checkLogin();
    #create DB handle
    my $DBH = createDBH();
    my $realRes = decode_json getAll(getUserIDN(attempt_login()->{username}, $DBH), $DBH);
    my %resourceHash;
    foreach my $hash (@{$realRes->{resources}}) {
        %resourceHash = (%resourceHash, %{$hash});
    }

    my %tempHash = (
        nowtime => time(),
        user_data => {
            username => "shortland",
            level => 123, 
            power => 90909090, 
            corporation => "-", 
        },
        planet_data => {
            system_name => "Meep A Sheep", 
            system_x => 1234, 
            system_y => 1234,
            index => 0,
        },
        building_level_data => {
            metal => 1, 
            crystal => 1, 
            gas => 1, 
            cc => 1, 
            lab => 1, 
            shipyard => 1, 
            corphq => 1, 
            globalmarket => 1, 
            stockmarket => 1, 
            radar => 1, 
            itemmender => 1, 
        },
        upgrade_status_data => {
            metal => 0,
            crystal => 0,
            gas => 0,
            cc => 0,
            lab => 0,
            shipyard => 0,
            corphq => 0,
            globalmarket => 0,
            stockmarket => 0,
            radar => 0,
            itemmender => 0,
        },
        upgrade_time_data => {
            metal => 0,
            crystal => 0,
            gas => 0,
            cc => 0,
            lab => 0,
            shipyard => 0,
            corphq => 0,
            globalmarket => 0,
            stockmarket => 0, 
            radar => 0,
            itemmender => 0,
        },
        current_income_data => {
            cash => 500,
            metal => 500,
            crystal => 500,
            gas => 500,
            lastUpdate => time(),
        }
    );

    $tempHash{current_resource_data} = \%resourceHash;
    #$tempHash{current_income_data} = \%incomeData;
    my $tempHash = encode_json(\%tempHash);

    print "localStorage.setItem('accountNumber1', JSON.stringify($tempHash));";
}