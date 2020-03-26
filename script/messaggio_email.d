#!/usr/bin/perl

=pod
Скрипту необходимо право на запись в /var/run/
=cut

use strict;
use warnings;
use lib::abs qw| ../lib .|;
use FindBin qw( $Bin );

use Proc::Daemon;
use Proc::PID::File;
use Config::JSON;
use Data::Dumper qw( Dumper );
use MessaggioEmail::Model::Message;

$SIG{__WARN__} = sub {
    my $datetime = localtime;
    warn $datetime, ' ', @_;
};

my $log_dir  = '/var/log/';
my $log_name = 'messaggio_email.d.log';
my $log_path = $log_dir . $log_name;

my $config_path = $Bin .'/../messaggio_email.json';
my $pause = 10;
my $pause_flag = 1;
my $config = Config::JSON->new( $config_path );
my $mes = MessaggioEmail::Model::Message->new( $config->config );

# Daemonize
my $res = Proc::Daemon::Init();#{ work_dir => '/var/tmp/' }
warn Dumper $res;

# Если демон уже запущен, то просто выходим.
if (Proc::PID::File->running()) {
    print "Already running\n";
    exit 0;
}

# инициализируем демона
# Enter loop to do work
while ( 1 ) {
    if ( 1 ) {
        unless ( $mes->proccess ) {
            #warn "Queue is empty\n";
            sleep $pause;
        }
    }
}


