package Kintai::Web::Controller::Kintai;
use strict;
use warnings;
use Time::Piece;
use Calendar::Japanese::Holiday;

sub index {
    my ($class, $c) = @_;

    my $year_month = $c->req->param('year_month') // localtime->strftime("%Y%m");

    my $next = Time::Piece->strptime( $year_month, '%Y%m' )->add_months(1)->strftime('%Y%m');
    my $prev = Time::Piece->strptime( $year_month, '%Y%m' )->add_months(-1)->strftime('%Y%m');

    my $month_table = create_month_table($year_month);
    my @day_list = get_day_list( $year_month );

    my $kintai = $c->db->single(
        kintai => { year_month => $year_month }
    );

    unless($kintai) {
        return $c->render('kintai.tx' => {
                year_month => $year_month,
                next => $next,
                prev => $prev,
                kintai => $month_table,
                total_work_time => format_jp_time_from_minutes(0),
                day_list => \@day_list,
        });
    }

    my $itr = $c->db->search(
        kintai_detail => {
            kintai_id => $kintai->id,
        },{
            order_by => 'day ASC',
        }
    );

    my $total_work_minutes = 0;
    while( my $row = $itr->next ) {

        my $break_minutes = calc_break_minutes( $row->attend_time, $row->leave_time );
        my $work_minutes = calc_work_minutes( $row->attend_time, $row->leave_time, $break_minutes );
        $total_work_minutes += $work_minutes;

        my $month_row = $month_table->{ $row->day };
        $month_row->{kintai_detail_id} = $row->id;
        $month_row->{attend_time} = format_time($row->attend_time);
        $month_row->{leave_time} = format_time($row->leave_time);
        $month_row->{break_time} = format_jp_time_from_minutes( $break_minutes );
        $month_row->{work_time} = format_jp_time_from_minutes( $work_minutes );
        $month_row->{remarks} = $row->remarks;
    }

    return $c->render('kintai.tx' => {
            year_month => $year_month,
            next => $next,
            prev => $prev,
            kintai => $month_table,
            total_work_time => format_jp_time_from_minutes( $total_work_minutes ),
            day_list => \@day_list,
    });
}

sub update {
    my ($class, $c) = @_;
    my $year_month = $c->req->param('year_month');
    my $attend_time = sprintf( "%02d%02d", $c->req->param("attend_hour"), $c->req->param("attend_min") );
    my $leave_time = sprintf( "%02d%02d", $c->req->param("leave_hour"), $c->req->param("leave_min") );

    # TODO: トランザクション

    my $kintai = $c->db->single(
        kintai => { year_month => $year_month }
    );

    unless($kintai) {
        $c->db->insert(
            kintai => {
                year_month => $year_month,
            },
        );

        $kintai = $c->db->single(
            kintai => {
                year_month => $year_month,
            },
        );
    }

    $c->db->insert(
        kintai_detail => {
            kintai_id => $kintai->id,
            day => $c->req->param('day'),
            attend_time => $attend_time,
            leave_time => $leave_time,
            remarks => $c->req->param('remarks'),
        },
    );

    return $c->redirect('/kintai', { year_month => $year_month } );
}

sub delete {
    my ($class, $c) = @_;
    my $year_month = $c->req->param('year_month');
    my $kintai_detail_id = $c->req->param('kintai_detail_id');

    my $kintai = $c->db->delete(
        kintai_detail => { id => $kintai_detail_id },
    );

    return $c->redirect('/kintai', { year_month => $year_month } );
}

sub calc_break_minutes {
    my( $attend_time, $leave_time ) = @_;

    my $attend = substr( $attend_time, 0, 2 ) * 60 + substr( $attend_time, 2, 2 );
    my $leave = substr( $leave_time, 0, 2 ) * 60 + substr( $leave_time, 2, 2 );

    my $break_start = 12 * 60;
    my $break_end = 13 * 60;

    if( $attend >= $break_end || $break_start >= $leave ) {
        return 0;
    }

    $attend = ( $attend > $break_start ? $attend : $break_start );
    $leave = ( $break_end > $leave ? $leave : $break_end );

    return $leave - $attend;
}

sub calc_work_minutes {
    my( $attend_time, $leave_time, $break_minutes ) = @_;

    my $attend = substr( $attend_time, 0, 2 ) * 60 + substr( $attend_time, 2, 2 );
    my $leave = substr( $leave_time, 0, 2 ) * 60 + substr( $leave_time, 2, 2 );

    return $leave - $attend - $break_minutes;
}

sub format_jp_time_from_minutes {
    my $minutes = shift;
    return do {
        if( $minutes < 60 ) {
            sprintf( "%d分", $minutes );
        } elsif( $minutes % 60 ) {
            sprintf( "%d時間%d分", $minutes / 60, $minutes % 60 );
        } else {
            sprintf( "%d時間", $minutes / 60, $minutes % 60 );
        }
    };
}

sub create_month_table {
    my $year_month = shift;

    my $year = substr( $year_month, 0, 4 );
    my $month = substr( $year_month, 4, 2 );
    my $last_day  = Time::Piece->strptime( $year.$month, '%Y%m' )->month_last_day;

    #TODO 定数化
    my @week_names = qw/日 月 火 水 木 金 土/;

    my $month_table;
    for my $day ( 1..$last_day ) {

        my $date = Time::Piece->strptime( $year.$month.$day, '%Y%m%d' );
        my $holiday = isHoliday( $year, $month+0, $day+0, 1 );
        my $line_color = do {
            if( $holiday or $date->wday == 1 ) {
                "danger";
            } elsif( $date->wday == 7 ) {
                "info";
            } else {
                ""
            }
        };

        $month_table->{$day} = {
            wday => $date->wdayname(@week_names),
            line_color => $line_color,
            remarks => $holiday,
        };
    }

    return $month_table;
}

sub get_day_list {
    my $year_month = shift;
    return 1..Time::Piece->strptime( $year_month, '%Y%m' )->month_last_day;
}

sub format_date {
    Time::Piece->strptime($_[0], '%Y%m%d')->ymd("/");
}

sub format_time {
    return substr( $_[0], 0, 2 ).":".substr( $_[0], 2, 2 );
#    Time::Piece->strptime($_[0], '%H%M')->strftime("%H:%M");
}

1;

