package Kintai::API;
use strict;
use warnings;
use utf8;
use parent qw/Kintai Amon2::Web/;
use File::Spec;

# dispatcher
use Kintai::API::Dispatcher;
sub dispatch {
    return (Kintai::API::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::JSON'
);

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;
        $res->header( 'X-Content-Type-Options' => 'nosniff' );
    },
);

1;

