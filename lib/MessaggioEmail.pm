package MessaggioEmail;

use Mojo::Base 'Mojolicious';
use MessaggioEmail::Model::Queue;
use Mojolicious::Plugins;
use Mojo::Util qw();

# This method will run once at server start
sub startup {
    my $c = shift;
    $c->secrets(['Messaggio#!>_Email']);

    # Documentation browser under "/perldoc"
    $c->plugin('PODRenderer');

    $c->helper( dumper => sub {
        shift;
        Mojo::Util::dumper \@_;
    });

    state $config = $c->plugin('JSONConfig');
    $c->helper( config => sub { $config });

    $c->helper( queue => sub {
        state $queue = MessaggioEmail::Model::Queue->new( $c->config->{ Redis } );
    });


    # Router
    my $r = $c->routes;

    # Normal route to controller
    #$r->get('/')->to('example#welcome');
    $r->get('/')->to('notifs#welcome');
    #$r->get( '/notifs')->to('notifs#list');
    $r->post('/notifs')->to('notifs#sendto');
    $r->get('/notifs/queue')->to('notifs#queueshow');
    #$r->get('/notifs/:id')->to('notifs#item');
}

1;
