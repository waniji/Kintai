package Kintai::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Amon2::Web::Dispatcher::RouterBoom;

any '/' => sub {
    my ($c) = @_;
    my @users = $c->db->search(
        user => {}, { order_by => {'id' => 'ASC' }}
    );
    return $c->render('index.tx' => {
        users => \@users,
    });
};

get '/user/create' => sub {
    my ($c) = @_;
    my @users = $c->db->search(
        user => {}, { order_by => {'id' => 'ASC' }}
    );
    return $c->render('user_create.tx' => {
            users => \@users,
    });
};

post '/user/create' => sub {
    my ($c) = @_;
    my $name = $c->req->param('name');

    $c->db->insert(
        user => {
            name => $name,
        },
    );

    return $c->redirect('/user/create');
};

get '/kintai' => sub {
    my ($c) = @_;

    my $user_id = $c->req->param('user_id');
    my $year_month = $c->req->param('year_month') // localtime->strftime("%Y%m");

    my $kintai = $c->db->single(
        kintai => { user_id => $user_id, year_month => $year_month }
    );

    unless($kintai) {
        return $c->render('kintai.tx' => {
                user_id => $user_id,
                kintai => [],
                year_month => $year_month,
        });
    }

    my $itr = $c->db->search(
        kintai_detail => {
            kintai_id => $kintai->id,
        },{
            order_by => 'day ASC',
        }
    );

    my @kintai;
    while( my $row = $itr->next ) {
        push @kintai, {
            date => format_date( $year_month.$row->day ),
            attend_time => format_time($row->attend_time),
            leave_time => format_time($row->leave_time),
            remarks => $row->remarks,
        };
    }

    return $c->render('kintai.tx' => {
            user_id => $user_id,
            kintai => \@kintai,
            year_month => $year_month,
    });
};

post '/kintai' => sub {
    my ($c) = @_;
    my $user_id = $c->req->param('user_id');
    my $date = $c->req->param('date');
    my $year_month = substr($date,0,6);
    my $day = substr($date,6,2);

    # TODO: トランザクション

    my $kintai = $c->db->single(
        kintai => { user_id => $user_id, year_month => $year_month }
    );

    unless($kintai) {
        $c->db->insert(
            kintai => {
                user_id => $user_id,
                year_month => $year_month,
            },
        );

        $kintai = $c->db->single(
            kintai => {
                user_id => $user_id,
                year_month => $year_month,
            },
        );
    }

    $c->db->insert(
        kintai_detail => {
            kintai_id => $kintai->id,
            day => $day,
            attend_time => $c->req->param('attend_time'),
            leave_time => $c->req->param('leave_time'),
            remarks => $c->req->param('remarks'),
        },
    );

    return $c->redirect('/kintai', { user_id => $user_id, year_month => $year_month } );
};

post '/account/logout' => sub {
    my ($c) = @_;
    $c->session->expire();
    return $c->redirect('/');
};

}

sub format_date {
    Time::Piece->strptime($_[0], '%Y%m%d')->ymd("/");
}

sub format_time {
    Time::Piece->strptime($_[0], '%H%M')->strftime("%H:%M");
}

1;
