package MessaggioEmail;

use Mojo::Base 'Mojolicious';
use MessaggioEmail::Model::Queue;


# This method will run once at server start
sub startup {
    my $self = shift;

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');
    $self->secrets(['Messaggio#!>_Email']);
    $self->helper( queue => sub {
        state $queue = MessaggioEmail::Model::Queue->new;
        #return $queue;
    });


    # Router
    my $r = $self->routes;

    # Normal route to controller
    #$r->get('/')->to('example#welcome');
    $r->get('/')->to('notifs#welcome');
    #$r->get( '/notifs')->to('notifs#list');
    $r->post('/notifs')->to('notifs#sendto');
    $r->get('/notifs/queue')->to('notifs#queueshow');
    #$r->get('/notifs/:id')->to('notifs#item');
}

1;
