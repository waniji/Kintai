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
    my $itr = $c->db->search(
        kintai => {
            user_id => $user_id,
        },{
            order_by => 'date ASC',
        }
    );

    my @kintai;
    while( my $row = $itr->next ) {
        my $fmt_date = $row->date =~ s!(\d{4})(\d{2})(\d{2})!$1/$2/$3!r;
        my $fmt_attend_time = $row->attend_time =~ s!(\d{2})(\d{2})!$1:$2!r;
        my $fmt_leave_time = $row->leave_time =~ s!(\d{2})(\d{2})!$1:$2!r;
        push @kintai, {
            user_id => $row->user_id,
            date => $fmt_date,
            attend_time => $fmt_attend_time,
            leave_time => $fmt_leave_time,
            remarks => $row->remarks,
        };
    }

    return $c->render('kintai.tx' => {
            user_id => $user_id,
            kintai => \@kintai,
    });
};

post '/kintai' => sub {
    my ($c) = @_;
    my $user_id = $c->req->param('user_id');

    $c->db->insert(
        kintai => {
            user_id => $user_id,
            date => $c->req->param('date'),
            attend_time => $c->req->param('attend_time'),
            leave_time => $c->req->param('leave_time'),
            remarks => $c->req->param('remarks'),
        },
    );

    return $c->redirect('/kintai', { user_id => $user_id } );
};

post '/account/logout' => sub {
    my ($c) = @_;
    $c->session->expire();
    return $c->redirect('/');
};

1;
