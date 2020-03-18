package MessaggioEmail::Model::Queue;

use strict;
use warnings;
use feature qw{ state };
use Redis;

sub new {
    my $class = shift;
    my $config = shift;
    die "ERROR: MessaggioEmail::Model::Queue: without config is not work\n"
        unless $config;

    my $self = bless { config => $config }, $class;
    $self->_init;
    return $self
}

sub queue {
    my $self = shift;
    state $redis = Redis->new(
        server => $self->_config->{server} .':'. $self->_config->{port},#'127.0.0.1:6379',
        name   => $self->_config->{name},#'MessaggioEmail_connection_name',
    );
}

sub _init {
    my $self = shift;
    $self->queue;
}

sub _queue_name { 'queue_1' }

sub _config {
    my $self = shift;
    return $self->{ config };
}

sub add {
    my ( $self, $value ) = @_;
    return
        unless $value;
    $self->queue->lpush( $self->_queue_name, $value );
}

sub get {
    my $self = shift;
    $self->queue->rpop( $self->_queue_name );
}

sub all {
    my $self = shift;
    $self->queue->lrange( $self->_queue_name, 0, -1 );
}



1;