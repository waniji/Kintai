#!/usr/bin/env perl
use strict;
use warnings;
use Encode qw/encode_utf8 decode_utf8/;
use Spreadsheet::ParseExcel;
use Time::Piece;
use Furl;

use constant {
    YEAR_MONTH => {
        row => 4,
        col => 9,
    },
    DAY => {
        col => 0,
    },
    ATTEND => {
        col => 2,
    },
    LEAVE => {
        col => 3,
    },
    REMARKS => {
        col => 7,
    },
};

my $user_id = 1;
my $furl = Furl->new(
    agent   => 'Furl/2.0',
    timeout => 10,
);
my $parser   = Spreadsheet::ParseExcel->new();

for my $file (@ARGV) {
    update_kintai_from_xls($file);
}

exit;

sub update_kintai_from_xls {
    my $file = shift;

    my $workbook = $parser->parse($file);
    if ( !defined $workbook ) {
        warn $parser->error(), ".\n";
        return;
    } else {
        print $file, "\n";
    }

    for my $worksheet ( $workbook->worksheets() ) {

        my $target = $worksheet->get_cell( YEAR_MONTH->{row}, YEAR_MONTH->{col} );

        my( $year, $month ) = do {
            $target->value =~ m!(?<year>\d+)/(?<month>\d+)!;
            ( $+{year}, $+{month} );
        };

        print $year, $month, "\n";
        my $year_month = Time::Piece->strptime( "$year/$month", '%y/%m' )->strftime('%Y%m');

        for my $row ( 11..41 ) {

            next unless $worksheet->get_cell( $row, ATTEND->{col} )->unformatted;

            my $day     = $worksheet->get_cell( $row, DAY->{col} );
            my $attend = 24 * 60 * $worksheet->get_cell( $row, ATTEND->{col} )->unformatted;
            my $attend_hour = $attend / 60;
            my $attend_min = $attend % 60;
            my $leave   = 24 * 60 * $worksheet->get_cell( $row, LEAVE->{col} )->unformatted;
            my $leave_hour = $leave / 60;
            my $leave_min = $leave % 60;
            my $remarks = $worksheet->get_cell( $row, REMARKS->{col} );

            my $res = $furl->post(
                'http://192.168.174.128:5000/api/kintai',
                [],
                [
                    user_id => $user_id,
                    year_month => $year_month,
                    day => $day->value,
                    attend_hour => $attend_hour,
                    attend_min => $attend_min,
                    leave_hour => $leave_hour,
                    leave_min => $leave_min,
                    remarks => encode_utf8( $remarks->value ),
                ],
            );
        }
    }
}

