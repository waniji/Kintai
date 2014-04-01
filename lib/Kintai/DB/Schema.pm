package Kintai::DB::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;
table {
    name 'kintai';
    pk 'id';
    columns (
        'id',
        'user_id',
        'year_month',
    );
};

table {
    name 'kintai_detail';
    pk 'id';
    columns (
        'id',
        'kintai_id',
        'day',
        'attend_time',
        'leave_time',
        'remarks',
    );
};

table {
    name 'sqlite_sequence';
    pk ;
    columns (
        'name',
        'seq',
    );
};

table {
    name 'user';
    pk 'id';
    columns (
        'id',
        'name',
    );
};

1;
