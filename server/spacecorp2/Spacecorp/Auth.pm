package Spacecorp::Auth;

use strict;
use warnings;

use CGI;
use CGI::Cookie;
use DBI;
use YAML::XS 'LoadFile';
use JSON;
use Crypt::PBKDF2;
use String::Random;
use Spacecorp::Regex qw(isCharNum);
 
use Exporter qw(import);
use Data::Dumper;
our @EXPORT_OK = qw(getUserIDN userExists createDBH isNotValidDetails hashPassword isUserPasswordValid getUserHash setCookiesEIE makeNewCookies updateDBCookies);

sub getUserIDN {
    my ($u, $DBH) = @_;
    my $sth = $DBH->prepare("SELECT IDN FROM user WHERE username = ?");
    $sth->execute($u) or die "Couldn't execute statement: $DBI::errstr; stopped";
    return $sth->fetchrow_hashref()->{IDN};
}

sub updateDBCookies {
    my ($u, $uC, $pC, $DBH) = @_;
    my $sth = $DBH->prepare("UPDATE user SET u_cookie = ?, p_cookie = ? WHERE username = ?");
    $sth->execute($uC, $pC, $u) or return 0;
    return 1;
}

sub makeNewCookies {
    my $uC = String::Random->new->randregex('\w{16}');
    my $pC = String::Random->new->randregex('\w{16}');
    return ($uC, $pC);
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

# create $dbh handler
sub createDBH {
    my ($DATABASE) = @_;
    if (!defined $DATABASE) {
        $DATABASE = "spacecorp";
    }    
    my $config = LoadFile('/var/www/html/spacecorp2/Spacecorp/.config.yaml');
    return DBI->connect("DBI:mysql:database=$DATABASE;host=localhost", $config->{sql}{user}, $config->{sql}{pass}, {'RaiseError' => 1});
}

# returns true if user already exists
sub userExists {
    my ($u, $DBH) = @_;
    my $sth = $DBH->prepare("SELECT hash FROM user WHERE username = ?");
    $sth->execute($u) or die "Couldn't execute statement: $DBI::errstr; stopped";
    while(my($hash) = $sth->fetchrow_array()) {
        return 1;
    }
    return 0;
}

# returns s/hashed password
sub hashPassword {
    my ($p) = @_;
    #set hashing values
    my $pbkdf2 = getHashSettings();
    return $pbkdf2->generate($p);
}

# returns true if the password matches hash
sub isUserPasswordValid {
    my ($hash, $p) = @_;
    my $pbkdf2 = getHashSettings();
    if ($pbkdf2->validate($hash, $p)) {
        return 1;
    }
    else {
        return 0;
    }
}

sub getHashSettings {
    return Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 21,
        salt_len => 10,
    );
}

# get hash of user
sub getUserHash {
    my ($u, $DBH) = @_;
    my $sth = $DBH->prepare("SELECT hash FROM user WHERE username = ?");
    $sth->execute($u) or die "Couldn't execute statement: $DBI::errstr; stopped";
    $sth->fetchrow_hashref()->{hash};
}

# check is username and password are valid parameters
sub isNotValidDetails {
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
    elsif (!isCharNum $u) {
        return {error => JSON::true, response => "user not charNum"};
    }
    else {
        return 0;
    }
}
1;