package Kintai::Web::Dispatcher;
use strict;
use warnings;
use utf8;
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
    my $year_month = $c->req->param('year_month') // now_year_month();

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
        my $fmt_date = sprintf( "%04d/%02d/%02d", substr($year_month,0,4), substr($year_month,4,2), $row->day );
        my $fmt_attend_time = $row->attend_time =~ s!(\d{2})(\d{2})!$1:$2!r;
        my $fmt_leave_time = $row->leave_time =~ s!(\d{2})(\d{2})!$1:$2!r;
        push @kintai, {
            user_id => $user_id,
            date => $fmt_date,
            attend_time => $fmt_attend_time,
            leave_time => $fmt_leave_time,
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

sub now_year_month {
    my ($mon,$year) = (localtime)[4,5];
    sprintf( "%04d%02d", $year+1900, $mon+1 );
}

1;
