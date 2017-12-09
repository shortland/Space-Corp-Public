package Spacecorp::ErrorRecorder;

use strict;
use warnings;
use DBI;
use YAML::XS 'LoadFile';
 
use Exporter qw(import);
 
our @EXPORT_OK = qw(record_error);

sub record_error {
	my (%info) = @_;
    my $config = LoadFile('../Spacecorp/.config.yaml');
    my $DBH = DBI->connect("DBI:mysql:database=spacecorp;host=localhost", $config->{sql}{user}, $config->{sql}{pass}, {'RaiseError' => 1});;
    $config = undef;
    my $sth = $DBH->prepare("
        INSERT INTO error 
        (ip, uas, ref, page, u_cookie, p_cookie, time, line, typical, severity)
        VALUES 
        (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $info{SEVERITY} = 'low' unless defined $info{SEVERITY};
    if ($info{SEVERITY} =~ /^high$/) {
    	`curl -s "http://138.197.50.244/spacecorp2/textMe.php?m=URGENT"`;
    }
    $info{U_COOKIE} = 'null' unless defined $info{U_COOKIE};
    $info{P_COOKIE} = 'null' unless defined $info{P_COOKIE};
    $sth->execute($ENV{REMOTE_ADDR}, $ENV{HTTP_USER_AGENT}, $info{REFERER}, $info{PAGE_NAME}, $info{U_COOKIE}, $info{P_COOKIE}, time(), $info{LINE}, $info{NORM}, $info{SEVERITY}) or return 0;
    $DBH->disconnect;
}
 
1;

#$ENV{REMOTE_ADDR}, $ENV{HTTP_USER_AGENT}