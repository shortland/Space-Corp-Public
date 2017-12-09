package Spacecorp::LoggedIn;

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use YAML::XS 'LoadFile';
 
use Exporter qw(import);
use Data::Dumper;
our @EXPORT_OK = qw(attempt_login);

sub attempt_login {
	my $cgi = new CGI;
	if (!defined $cgi->cookie('uCookie') && !defined $cgi->cookie('pCookie')) {
		return undef;
	}
	if (length $cgi->cookie('uCookie') ne 16 || length $cgi->cookie('pCookie') ne 16) {
		return undef
	}
    my $config = LoadFile('../Spacecorp/.config.yaml');
	my $DBH = DBI->connect("DBI:mysql:database=spacecorp;host=localhost", $config->{sql}{user}, $config->{sql}{pass}, {'RaiseError' => 1});
    my $sth = $DBH->prepare("SELECT username FROM user WHERE u_cookie = ? AND p_cookie = ?");
    $sth->execute($cgi->cookie('uCookie'), $cgi->cookie('pCookie')) or return 0;
    return $sth->fetchrow_hashref();
}

1;