package MessaggioEmail::Model::Mail;

use strict;
use warnings;

use Email::Sender;

sub new {
    my $class  = shift;
    my $config = shift;
    die "ERROR: MessaggioEmail::Model::Mail: without config is not work\n"
        unless $config;

    my $self = bless { config => $config }, $class;
    $self->_init;
    return $self
}

sub _init {
    my $self = shift;
}

sub _config {
    my $self = shift;
    return $self->{ config };
}

sub send {
    my $self = shift;
}


1;