package Kintai::DB::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;
table {
    name 'kintai';
    pk 'user_id','date';
    columns (
        'user_id',
        'date',
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
