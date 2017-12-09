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

BEGIN {
    my $cgi = new CGI;
    print $cgi->header(-type => "text/plain", -status => "200 OK");
    print "Hello!\n";

    if (defined attempt_login()) {
        print attempt_login()->{username} . "\n";
    }
    else {
        print "You're not logged in.\n";
    }
}