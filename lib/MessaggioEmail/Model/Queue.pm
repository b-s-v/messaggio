package MessaggioEmail::Model::Queue;

use strict;
use warnings;
use Redis;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->_init;
    return $self
}

sub queue {
    my $self = shift;
    $self->{ redis } //= Redis->new(
        server => '127.0.0.1:6379',
        name   => 'MessaggioEmail_connection_name',
    );
}

sub _init {
    my $self = shift;
    $self->queue;
}
sub _queue_name { 'queue_1' }
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