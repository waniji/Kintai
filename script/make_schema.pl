#!perl
use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../lib');

use Kintai;
use Teng::Schema::Dumper;

my $c = Kintai->bootstrap;
my $conf = $c->config->{Teng};

my $dbh = DBI->connect(
    $conf->[0],
    $conf->[1]
) or die "Cannot connect to DB:: " . $DBI::errstr;

my $schema = Teng::Schema::Dumper->dump(dbh => $dbh, namespace => 'Kintai::DB');

my $dest = File::Spec->catfile($FindBin::Bin, '..', 'lib', 'Kintai', 'DB', 'Schema.pm');
open my $fh, '>', $dest or die "cannot open file '$dest': $!";
print {$fh} $schema;
close;

