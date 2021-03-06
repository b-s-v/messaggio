package MessaggioEmail::Model::Message;

use strict;
use warnings;
use feature qw{ state };
use lib::abs qw| ../../../lib .|;

use DBI;
use Mojo::JSON qw(decode_json encode_json);
use Encode;
use Data::Dumper qw(Dumper);

use MessaggioEmail::Model::Queue;
use MessaggioEmail::Model::Mail;

use constant {
    FIELDS_ALL  => [ qw( sender to subject message ) ],
    FIELDS_NEED => [ qw(        to subject message ) ],
};

$SIG{__WARN__} = sub {
    my $datetime = localtime;
    warn $datetime, ' ', @_;
};

sub new {
    my $class = shift;
    my $config = shift;
    die "ERROR: MessaggioEmail::Model::Message: without config is not work\n"
        unless $config;

    my $self = bless { config => $config }, $class;
    $self->_init;
    return $self
}

sub _dbh {
    my $self = shift;
    #warn "# _config MainDB => ", Dumper $self->_config->{ MainDB };
    $self->{ dbh } ||= DBI->connect(
        $self->_config->{ MainDB }{ dsn      },
        $self->_config->{ MainDB }{ user     },
        $self->_config->{ MainDB }{ password },
        {}
    ) or die $DBI::errstr;

    my $state = $self->{ dbh }->state;
    #warn "# state connect to db [$state]\n";
    unless ( $state eq '00000' ) {
        #warn "# reconnect\n";
        $self->{ dbh } = DBI->connect(
            $self->_config->{ MainDB }{ dsn      },
            $self->_config->{ MainDB }{ user     },
            $self->_config->{ MainDB }{ password },
            {}
        ) or die $DBI::errstr;
    }
}

sub _queue {
    my $self = shift;
    state $queue = MessaggioEmail::Model::Queue->new( $self->_config->{ Redis } );
}

sub _mail {
    my $self = shift;
    state $queue = MessaggioEmail::Model::Mail->new( $self->_config->{ Mail } );
}

sub _init {
    my $self = shift;
    $self->_dbh;
    $self->_queue;
    $self->_mail;
}

sub _config {
    my $self = shift;
    return $self->{ config };
}

# получить сообщение из очереди
sub get {
    my $self = shift;
    my $message = $self->_queue->get;#Encode::encode( "utf8",  )
    warn "get queue => [$message]\n"
        if $message;
    return $message
         ? decode_json $message
         : {};

}

# Отправить сообщение адресату
sub send {
    my $self = shift;
    my $message = shift;

    $self->_mail->send( $message );
}

# Сохранить сообщение в базу и статус обработки
sub save {
    my $self = shift;
    my $params = shift;
    #warn "#[$$] params => ", Dumper $params;
    $params->{ to } = [ $params->{ to } ]
        unless ref $params->{ to };

    my @fields = @{ FIELDS_ALL() };#qw( sender subject to message status );
    unshift @fields, 'id'
        if $params->{ id };
    push @fields, 'status'
        if $params->{ status };


    my @values = map {
        $params->{ $_ }
    } @fields;
    #warn "# values for save => ", Dumper \@values;

    my $sql = q!
INSERT INTO message.items ( !. join( ', ', map {'"'. $_ .'"'} @fields ) .q! )
VALUES ( !. join( ', ', map { '?' } @fields ) .q! )
RETURNING id
    !;
    #warn "# sql [$sql]\n";

    my $id = $self->_dbh->do( $sql, {}, @values ) or warn $self->_dbh->errstr;

    return 1;
}

sub proccess {
    my $self = shift;
    my $message = $self->get;
    return 0
        unless keys %$message;

    warn "# proccess message [$message->{ id }]\n";
    $message->{ status } = $self->send( $message );
    warn "# proccess message [$message->{ id }] send => [$message->{ status }]\n";

    my $status_save = $self->save( $message );
    warn "# proccess message [$message->{ id }] save => [$status_save]\n";
    return 1;
}

sub validate {
    my $emails = shift;
    $emails = [ split /\s|\s*,\s*|;|/, $emails ]
        unless ref $emails;
    my $status = 1;
    my $qr_address = qr_address();
    foreach my $item ( @$emails ) {
        $status = 0 unless $item =~ m#$qr_address#;
    }
}

sub qr_address { state $qr_address = qr#[^ @]+@[^ @]+\.[a-z]+#i; }









1;