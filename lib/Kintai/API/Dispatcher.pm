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

post '/api/kintai' => sub {
    my ($c) = @_;

    my %params;
    my @require_param_keys = qw/user_id year_month day attend_hour attend_min leave_hour leave_min/;
    for my $key (@require_param_keys) {
        unless( defined $c->req->param ) {
            return $c->render_json( { status => "400 Bad Requests", message => "$key is required" } );
        }
        $params{$key} = $c->req->param($key);
    }
    $params{remarks} = $c->req->param('remarks');

    my $kintai = $c->db->single(
        kintai => {
            user_id => $params{user_id},
            year_month => $params{year_month},
        }
    );

    unless($kintai) {
        $c->db->insert(
            kintai => {
                user_id => $params{user_id},
                year_month => $params{year_month},
            },
        );

        $kintai = $c->db->single(
            kintai => {
                user_id => $params{user_id},
                year_month => $params{year_month},
            },
        );
    }

    $c->db->insert(
        kintai_detail => {
            kintai_id => $kintai->id,
            day => $params{day},
            attend_time => sprintf( "%02d%02d", $params{attend_hour}, $params{attend_min} ),
            leave_time => sprintf( "%02d%02d", $params{leave_hour}, $params{leave_min} ),
            remarks => $params{remarks},
        },
    );

    return $c->render_json( { status => "201 Created" } );
};

1;

