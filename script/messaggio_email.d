#!/usr/bin/perl

=pod
Скрипту необходимо право на запись в /var/run/
=cut

use strict;
use warnings;
use lib::abs qw| ../lib .|;
use FindBin qw( $Bin );

use Proc::Daemon; use Proc::PID::File;
use Config::JSON;
use Data::Dumper qw( Dumper );
use MessaggioEmail::Model::Message;

my $log_dir  = '/var/log/';
my $log_name = 'messaggio_email.d.log';
my $log_path = $log_dir . $log_name;

my $config_path = $Bin .'/../messaggio_email.json';
warn $config_path;
my $pause = 10;
my $pause_flag = 1;
my $config = Config::JSON->new( $config_path );
warn Dumper $config->config;
my $mes = MessaggioEmail::Model::Message->new( $config->config );
warn 0.1;

# Daemonize
my $res = Proc::Daemon::Init();#{ work_dir => '/var/tmp/' }
warn Dumper $res;

# Если демон уже запущен, то просто выходим.
if (Proc::PID::File->running()) {
    print "Already running\n";
    exit 0;
}
warn 1;

# инициализируем демона
# Enter loop to do work
while ( 1 ) {
    if ( 1 ) {
        unless ( $mes->proccess ) {
            warn "Queue is empty\n";
            sleep $pause;
        }
    }
}



=pod
$SIG{__WARN__} = sub {
    local $Log::Log4perl::caller_depth =
        $Log::Log4perl::caller_depth + 1;

    WARN @_;
};
$SIG{__DIE__} = sub {
    return if $^S;
    $Log::Log4perl::caller_depth++;

    LOGDIE @_;
};
$SIG{TERM} = sub { do_cleanup(); do_quit(); };

=cut