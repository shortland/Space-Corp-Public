#!/usr/bin/perl

#typical
use strict;
use warnings;
#personal
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/';
use Spacecorp::Regex qw(isCharNum isPosIntNotBin);
use Spacecorp::SystemNamer qw(random_system);
use Spacecorp::ErrorRecorder qw(record_error);
#general
use CGI;
use CGI::Cookie;
use CGI::Carp qw(fatalsToBrowser);
use JSON;
use YAML::XS 'LoadFile';
use DBI;
use String::Random;
use Crypt::PBKDF2;
#use Plack::Middleware::CrossOrigin;

# send me an email or some alert stating the max (100) collisions has occured... I don't think it's 100% possible but we'll see, i didn't really work too hard on the algo to create coords...
# I don't think 100+ collisions 
# sub maxCollisionsWithCoordinates {
#     print "o shit";
# }

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
            $info{LINE} = __LINE__; $info{NORM} = 'false'; $info{SEVERITY} = 'high'; record_error(%info);
            return 0;
        }
        else {
            $info{LINE} = __LINE__; $info{NORM} = 'false'; $info{SEVERITY} = 'medium'; record_error(%info);
            createCoordinates($idn, $attempts, $DBH);
        }
    }
    else {
        my $sth = $DBH->prepare("update user SET system_x = ?, system_y = ?, collisions = ? WHERE IDN = ?");
        $sth->execute($sysX, $sysY, $attempts, $idn) or return 0;
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
    # if ($rand >= 0.5) {
    my $sysX = (int(rand(1000000)) + 1);
    my $sysY = (int(rand(1000000)) + 1);
    registerCoordinates($idn, ++$attempts, $sysX, $sysY, $DBH);
    # }
    # else {
    #     # exponential model with linear correlation
    #     my $sysX = (int(rand(1000)) + 1) * $idn;
    #     my $sysY = (int(rand(100)) + 1) * $idn;
    #     registerCoordinates($idn, ++$attempts, $sysX, $sysY, $DBH);
    # }
}

# returns header to print, accepts type as argument to print. "json", "text", "text/html"
sub cleanHeaders {
    my ($cgi, $t) = @_;
    return $cgi->header(-type=>$t);
}

# set cookies regardless if cookies are already set
# even if exists
sub setCookiesEIE {
    my ($u, $p) = @_;
    my $uCookie = CGI::Cookie->new(-name => 'uCookie', -value => $u, -expires => '+3M');
    my $pCookie = CGI::Cookie->new(-name => 'pCookie', -value => $p, -expires => '+3M');
    print "Set-Cookie: $uCookie\n";
    print "Set-Cookie: $pCookie\n";
}

# registers a user, assumes that clashing usernames have already been checked for 
# returns IDN of newly registered user
sub registerUser {
    my ($user, $pass, $uCookieVal, $pCookieVal, $sysName, $DBH) = @_;
    #set hashing values
    my $pbkdf2 = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 21,
        salt_len => 10,
    );
    my $hash = $pbkdf2->generate($pass);
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

# returns only if user already exists
sub userExists {
    my ($u, $DBH) = @_;
    my $sth = $DBH->prepare("SELECT hash FROM user WHERE username = ?");
    $sth->execute($u) or die "Couldn't execute statement: $DBI::errstr; stopped";
    while(my($hash) = $sth->fetchrow_array()) {
        return {error => JSON::true, response => "user exists"};
    }
}

# create $dbh handler
sub createDBH {
    my ($SQLUSER, $SQLPASS) = @_;
    return DBI->connect("DBI:mysql:database=spacecorp;host=localhost", $SQLUSER, $SQLPASS, {'RaiseError' => 1});
}

# check is username and password are valid parameters
sub isValidDetails {
    my ($u, $p) = @_;
    if (!defined $u || !defined $p) {
        return {error => JSON::true, response => "undef username or password"};
    }
    elsif (length $u < 3 || length $p < 3) {
        return {error => JSON::true, response => "minimum length user pass"};
    }
    elsif (length $u > 14) {
        return {error => JSON::true, response => "maximum length user"}
    }
    elsif (length $p > 30) {
        return {error => JSON::true, response => "maximum length pass"}
    }
    elsif (!isCharNum $u) { #$pass can be whatever since we're hashing it
        return {error => JSON::true, response => "user not charNum"};
    }
    else {
        return 0;
    }
}

BEGIN {
    my $cgi = new CGI;
    #get posted user and pass
    my $user = $cgi->param('u');
    my $pass = $cgi->param('p');
    #error logging
    my (%info);
    $info{PAGE_NAME} = $0;
    $info{REFERER} = defined $ENV{HTTP_REFERER} ? $ENV{HTTP_REFERER} : 'NONE';
    $info{U_COOKIE} = $cgi->cookie('uCookie');
    $info{P_COOKIE} = $cgi->cookie('pCookie');
    #sql user and pass from YAML
    my $config = LoadFile('../Spacecorp/.config.yaml');
    my $DBH = createDBH($config->{sql}{user}, $config->{sql}{pass});
    $config = undef;
    #create random cookies
    my $uCookieVal = String::Random->new->randregex('\w{16}');
    my $pCookieVal = String::Random->new->randregex('\w{16}');
    #set cookies only if cookies aren't set already
    setCookiesINE($cgi, $uCookieVal, $pCookieVal);
    #check if supplied user and pass are valid
    if (isValidDetails($user, $pass)) {
        print cleanHeaders($cgi, "json");
        print encode_json isValidDetails($user, $pass);
        $info{LINE} = __LINE__; $info{NORM} = 'true'; record_error(%info);
        exit;
    }
    #check if the username already exists
    if (userExists($user, $DBH)) {
        print cleanHeaders($cgi, "json");
        print encode_json userExists($user, $DBH);
        $info{LINE} = __LINE__; $info{NORM} = 'true'; record_error(%info);
        exit;
    }
    #make a random system name for the new system coordinates
    # random_system();
    #== this is my "fix", get their ID, make random number 1-100 and make RandomNumber*ID = their X/Y coord. will need to loop as it's possible to get dupes. but not always dupes.
    my $userIDN = registerUser($user, $pass, $uCookieVal, $pCookieVal, random_system(), $DBH);
    if (!isPosIntNotBin($userIDN)) {
        setCookiesEIE("", "");
        print cleanHeaders($cgi, "json");
        print encode_json {error => JSON::true, response => "[DB]:Unknown error in registering user"};
        $info{LINE} = __LINE__; $info{NORM} = 'false'; record_error(%info);
        exit;
    }
    else {
        setCookiesEIE($uCookieVal, $pCookieVal);
        print cleanHeaders($cgi, "json");
        if (!createCoordinates($userIDN, 0, $DBH)) {
            print encode_json {error => JSON::true, response => "possible collision error"};
            $info{LINE} = __LINE__; $info{NORM} = 'false'; record_error(%info);
        }
        else {
            print encode_json {error => JSON::false, response => "successfully registered"};
        }
    }

    open(STDERR, ">&STDOUT");
}

