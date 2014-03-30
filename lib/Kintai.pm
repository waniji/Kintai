package Kintai;
use strict;
use warnings;
use utf8;
our $VERSION='0.01';
use 5.008001;
use Kintai::DB::Schema;
use Kintai::DB;

use parent qw/Amon2/;
# Enable project local mode.
__PACKAGE__->make_local_context();

my $schema = Kintai::DB::Schema->instance;

sub db {
    my $c = shift;
    if (!exists $c->{db}) {
        my $conf = $c->config->{Teng}
            or die "Missing configuration about Teng";
        $c->{db} = Kintai::DB->new(
            schema       => $schema,
            connect_info => [@$conf],
        );
    }
    $c->{db};
}

1;
__END__

=head1 NAME

Kintai - Kintai

=head1 DESCRIPTION

This is a main context class for Kintai

=head1 AUTHOR

Kintai authors.

