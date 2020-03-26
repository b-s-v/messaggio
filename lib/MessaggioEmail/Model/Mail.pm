package MessaggioEmail::Model::Mail;

use strict;
use warnings;

use Email::Sender;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP qw();
use Try::Tiny;
use Data::Dumper qw( Dumper );

$SIG{__WARN__} = sub {
    my $datetime = localtime;
    warn $datetime, ' ', @_;
};

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
    my $message = shift;

    my $email = Email::Simple->create(
        header => [
            From    => $message->{ sender },
            To      => $message->{ to },#join(',', @{  })baslerov@mail.ru',
            Subject => $message->{ subject },
        ],
        body => $message->{ message },
    );

    try {
        my $res = sendmail(
            $email,
            {
                from      => $message->{ sender } || $self->_config->{ smtp }{ from_for_smtp },#'feanor99@mail.ru',
                transport => Email::Sender::Transport::SMTP->new({
                    host          => $self->_config->{ smtp }{ host },
                    port          => $self->_config->{ smtp }{ port },
                    ssl           => $self->_config->{ smtp }{ ssl },
                    sasl_username => $self->_config->{ smtp }{ sasl_username },
                    sasl_password => $self->_config->{ smtp }{ sasl_password },
                })
            },
        );
        warn "# MessaggioEmail::Model::Mail res of send email [$message->{ id }] => [", $res->message, ']';
        return 1;
    }
    catch {
        warn "ERROR: MessaggioEmail::Model::Mail: email [$message->{ id }] sending failed: [$_]";
        return 0;
    };
}


1;