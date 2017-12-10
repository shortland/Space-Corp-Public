package Spacecorp::LoggedInLegacy;

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
	if (!defined $cgi->cookie('u_cookie') && !defined $cgi->cookie('p_cookie')) {
		return undef;
	}
	if (length $cgi->cookie('u_cookie') ne 16 || length $cgi->cookie('p_cookie') ne 16) {
		return undef
	}
    my $config = LoadFile('../Spacecorp/.config.yaml');
	my $DBH = DBI->connect("DBI:mysql:database=spacecorp;host=localhost", $config->{sql}{user}, $config->{sql}{pass}, {'RaiseError' => 1});
    my $sth = $DBH->prepare("SELECT username FROM user WHERE u_cookie = ? AND p_cookie = ?");
    $sth->execute($cgi->cookie('u_cookie'), $cgi->cookie('p_cookie')) or return 0;
    return $sth->fetchrow_hashref();
}

1;