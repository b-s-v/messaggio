package MessaggioEmail;

use Mojo::Base 'Mojolicious';
use Mojolicious::Plugins;
use Mojo::Util qw();
use DBI;

use MessaggioEmail::Model::Queue;
use MessaggioEmail::Model::Pager;

# This method will run once at server start
sub startup {
    my $c = shift;

    $c->init();

    # Router
    my $r = $c->routes;

    # Normal route to controller
    #$r->get('/')->to('example#welcome');
    $r->get('/')->to('notifs#welcome');
    #$r->get( '/notifs')->to('notifs#list');
    $r->get( '/notifs')->to('notifs#list_ajax');
    $r->post('/notifs')->to('notifs#sendto');
    $r->post( '/notifs/list_part_ajax')->to('notifs#list_part_ajax');
    $r->get('/notifs/queue')->to('notifs#queueshow');
    $r->get('/notifs/:id')->to('notifs#item');
}

sub init {
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
    #$c->helper( 'pager' );

    $c->helper( queue => sub {
        state $queue = MessaggioEmail::Model::Queue->new( $c->config->{ Redis } );
    });

    $c->helper( pager => sub {
        state $pager = MessaggioEmail::Model::Pager->new;
    });

    $c->helper( dbh => sub {
        state $dbh = DBI->connect(
            $c->config->{ MainDB }{ dsn      },
            $c->config->{ MainDB }{ user     },
            $c->config->{ MainDB }{ password },
            {}
        ) or die $DBI::errstr;
    });
}

1;
