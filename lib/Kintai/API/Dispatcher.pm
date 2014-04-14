package Kintai::API::Dispatcher;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Amon2::Web::Dispatcher::RouterBoom;
use Calendar::Japanese::Holiday;

get '/api/users' => sub {
    my ($c) = @_;
    my $itr = $c->db->search(
        user => {
        }, {
            order_by => {'id' => 'ASC' }
        }
    );

    my @users;
    while( my $row = $itr->next ) { 
        push @users, +{ id => $row->id, name => $row->name };
    }

    return $c->render_json(\@users);
};

1;

