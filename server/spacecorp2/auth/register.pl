#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use CGI::Cookie;
use CGI::Carp qw(fatalsToBrowser);

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/';
use Spacecorp::Regex qw(isCharNum isPosIntNotBin);
use Spacecorp::SystemNamer qw(random_system);
use Spacecorp::ErrorRecorder qw(record_error);
use Spacecorp::Auth qw(userExists createDBH isNotValidDetails hashPassword setCookiesEIE makeNewCookies);

use JSON;
use DBI;
use String::Random;
use Path::Tiny;
#use Plack::Middleware::CrossOrigin;

# inserts the default json values for userResources
# we can get the next level cost from mainFile based off of current level building
# we can get building income based off of level
sub insertDefaultData {
    my ($idn, $DBH) = @_;
    my $bLevels = path("default/bLevels.json")->slurp or return 0;
    my $bRemaining = path("default/bRemaining.json")->slurp or return 0;
    my $resources = path("default/resources.json")->slurp or return 0;
    my $sth = $DBH->prepare("INSERT INTO userResources (IDN, buildingLevels, buildingRemaining, resources, levelsTime, resourcesTime, remainingTime, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $sth->execute($idn, $bLevels, $bRemaining, $resources, time(), time(), time(), time()) or return 0;
    return 1;
}

# append the coordinates to the user, or if validation failed, attempt to create new random coordinates up to 100 times.
sub registerCoordinates {
    my ($idn, $attempts, $sysX, $sysY, $DBH) = @_;
    my (%info);
    $info{PAGE_NAME} = $0;
    $info{REFERER} = defined $ENV{HTTP_REFERER} ? $ENV{HTTP_REFERER} : 'NONE';
    $info{U_COOKIE} = 'NE pathway';
    $info{P_COOKIE} = 'NE pathway';
    if (!validateCoordinates($sysX, $sysY, $DBH)) {
        if ($attempts =~ /^100$/) {
            maxCollisionsWithCoordinates();
            logger(__LINE__, 'false', 'high');
            return 0;
        }
        else {
            logger(__LINE__, 'false', 'medium');
            createCoordinates($idn, $attempts, $DBH);
        }
    }
    else {
        my $sth = $DBH->prepare("UPDATE user SET system_x = ?, system_y = ?, collisions = ? WHERE IDN = ?");
        $sth->execute($sysX, $sysY, $attempts, $idn) or return 0;
        return 1;
    }
}

# check to see if those coordinates are in use
sub validateCoordinates {
    my ($x, $y, $DBH) = @_;
    my $sth = $DBH->prepare("SELECT hash FROM user WHERE system_x = ? AND system_y = ?");
    $sth->execute($x, $y) or die "Couldn't execute statement: $DBI::errstr; stopped";
    while(my($hash) = $sth->fetchrow_array()) {
        return 0;
    }
    return 1;
}

# create x/y coordinates for the registered user
sub createCoordinates {
    my ($idn, $attempts, $DBH) = @_;
    my $rand = rand();
    my $sysX = (int(rand(1000000)) + 1);
    my $sysY = (int(rand(1000000)) + 1);
    return registerCoordinates($idn, ++$attempts, $sysX, $sysY, $DBH);
}

# registers a user, assumes that clashing usernames have already been checked for 
# returns IDN of newly registered user
sub registerUser {
    my ($user, $pass, $uCookieVal, $pCookieVal, $sysName, $DBH) = @_;
    # get hash from hashingfunc
    my $hash = hashPassword($pass);
    #register user
    my $sth = $DBH->prepare("
        INSERT INTO user 
        (username, hash, u_cookie, p_cookie, upc_changed, create_ip, last_ip, create_ua, last_ua, last_login, system_name)
        VALUES 
        (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $sth->execute($user, $hash, $uCookieVal, $pCookieVal, time(), $ENV{REMOTE_ADDR}, $ENV{REMOTE_ADDR}, $ENV{HTTP_USER_AGENT}, $ENV{HTTP_USER_AGENT}, time(), $sysName) or return 0;
    #get users IDN
    $sth = $DBH->prepare("SELECT IDN FROM user WHERE username = ?");
    $sth->execute($user) or return 0;
    return $sth->fetchrow_hashref()->{IDN};
}

# set cookies only if cookies arent set
# if not exists
sub setCookiesINE {
    my ($cgi, $u, $p) = @_;
    if (defined $cgi->cookie('uCookie') || defined $cgi->cookie('pCookie')) {
        return 0;
    }
    else {
        my $uCookie = CGI::Cookie->new(-name => 'uCookie', -value => $u, -expires => '+3M');
        my $pCookie = CGI::Cookie->new(-name => 'pCookie', -value => $p, -expires => '+3M');
        print "Set-Cookie: $uCookie\n";
        print "Set-Cookie: $pCookie\n";
    }
}

sub logger {
    my @params = @_;
    my $cgi = new CGI;
    my (%info);
    $info{PAGE_NAME} = $0;
    $info{REFERER} = defined $ENV{HTTP_REFERER} ? $ENV{HTTP_REFERER} : 'NONE';
    $info{U_COOKIE} = defined $cgi->cookie('uCookie') ? $cgi->cookie('uCookie') : 'NONE';
    $info{P_COOKIE} = defined $cgi->cookie('pCookie') ? $cgi->cookie('pCookie') : 'NONE';
    $info{LINE} = $params[0]; 
    $info{NORM} = $params[1]; 
    $info{SEVERITY} = $params[2];
    return record_error(%info);
}

BEGIN {
    my $cgi = new CGI;
    #get posted user and pass
    my $user = $cgi->param('u');
    my $pass = $cgi->param('p');
    #sql user and pass from YAML
    my $DBH = createDBH();
    #create random cookies
    #set cookies only if cookies aren't set already, but why? vising register page acts like logout.
    my @newCookies = makeNewCookies();
    setCookiesEIE($newCookies[0], $newCookies[1]);
    print $cgi->header(-type => "application/json");
    #check if supplied user and pass are valid
    if (isNotValidDetails($user, $pass)) {
        print encode_json isNotValidDetails($user, $pass);
        exit;
    }
    #check if the username already exists
    if (userExists($user, $DBH)) {
        print encode_json {error => JSON::true, response => "user exists"};
        exit;
    }
    #make a random system name for the new system coordinates
    my $userIDN = registerUser($user, $pass, $newCookies[0], $newCookies[1], random_system(), $DBH);
    if (!isPosIntNotBin($userIDN)) {
        print encode_json {error => JSON::true, response => "[DB]:Unknown error in registering user"};
        logger(__LINE__, 'false');
        exit;
    }

    if (!createCoordinates($userIDN, 0, $DBH)) {
        print encode_json {error => JSON::true, response => "possible collision error"};
        logger(__LINE__, 'false');
        exit;
    }

    if (insertDefaultData($userIDN, $DBH)) {
        print encode_json {error => JSON::false, response => "successfully registered"};
    }
    else {
        print encode_json {error => JSON::true, response => "unable to initialize user resources"};
        logger(__LINE__, 'false');
        exit;
    }

    open(STDERR, ">&STDOUT");
}

