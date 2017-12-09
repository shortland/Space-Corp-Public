#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
#use Plack::Middleware::CrossOrigin;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/';
use Spacecorp::LoggedIn qw(attempt_login);
use Spacecorp::Auth qw(createDBH getUserIDN);
use Spacecorp::ResourceTransaction qw(getAll);

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
    print "your IDN is " . getUserIDN(attempt_login()->{username}, $DBH) . "\n\n";
    print getAll(getUserIDN(attempt_login()->{username}, $DBH), $DBH);
}