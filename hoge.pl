#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use Data::Dumper;
use Encode qw/encode_utf8/;
use Calendar::Japanese::Holiday;

# Getting a list of holidays
my $holidays = getHolidays(2014, 4);
say encode_utf8( $holidays->{29} );
$holidays = getHolidays(2008, 5, 1);
say Dumper $holidays;

# Examining whether it is holiday or not.
my $name = isHoliday("2007", "5", "5");
say $name;

my $hoge = "123456";

say substr( $hoge, 0, 4 );
say substr( $hoge, 4, 2 );
