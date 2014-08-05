package Kintai::Web::Controller::API;
use strict;
use warnings;

sub kintai {
    my ($class, $c) = @_;

    my %params;
    my @require_param_keys = qw/year_month day attend_hour attend_min leave_hour leave_min/;
    for my $key (@require_param_keys) {
        unless( defined $c->req->param ) {
            return $c->render_json( { status => "400 Bad Requests", message => "$key is required" } );
        }
        $params{$key} = $c->req->param($key);
    }
    $params{remarks} = $c->req->param('remarks');

    my $kintai = $c->db->single(
        kintai => {
            year_month => $params{year_month},
        }
    );

    unless($kintai) {
        $c->db->insert(
            kintai => {
                year_month => $params{year_month},
            },
        );

        $kintai = $c->db->single(
            kintai => {
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

