package Kintai::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Module::Find;

useall 'Kintai::Web::Controller';
base   'Kintai::Web::Controller';

get  '/' => 'Kintai#index';
get  '/kintai' => 'Kintai#index';
post '/kintai' => 'Kintai#update';
post '/kintai/delete' => 'Kintai#delete';
post '/api/kintai' => 'API#kintai';

1;
