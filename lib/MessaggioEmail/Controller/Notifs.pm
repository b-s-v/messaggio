package MessaggioEmail::Controller::Notifs;

use lib::abs qw| ../../../lib .|;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(decode_json encode_json);
use Data::Dumper qw(Dumper);
use UUID;

use MessaggioEmail::Model::Message;

use constant {
    ITEMS_IN_PAGE => 10,
};

$SIG{__WARN__} = sub {
    my $datetime = localtime;
    warn $datetime, ' ', @_;
};

# This action will render a template
sub welcome {}
sub sendto {
    my $c = shift;
    my @fields_all  = @{ MessaggioEmail::Model::Message::FIELDS_ALL() };#qw( sender to subject message );
    my @fields_need = @{ MessaggioEmail::Model::Message::FIELDS_NEED() };#qw(        to subject message );
    my $data = { map { $_ => $c->param( $_ ) } @fields_all };

    $data->{ id } = _uuid_generate();
    #warn "# notifs data ", Dumper $data;

    unless ( grep { !$data->{ $_ } } @fields_need ) {
        $c->render(
            json => {
                success => 0,
                params  => $c->req->params->to_hash,
                error   => {
                    str => 'NOT_ALL_FIELDS_OF_NEED_WAS_FILLED'
                }
            }
        );
    }

    warn "# message for queue => ", encode_json $data, "\n";
    my $res = $c->queue->add( encode_json $data );
    warn "# notifs queue->add res => [$res]\n";

    # Render template "example/welcome.html.ep" with message
    $c->render(
        json => {
            success => 1,
            params  => $c->req->params->to_hash,
            data    => {
                id     => $data->{ id },
                result => $res,
                str    => 'DATA_INTO_QUEUE_ADDED'
            }
        }
    );
}

sub _uuid_generate {
     my $uuid;
     my $string;
     UUID::generate( $uuid );
     UUID::unparse( $uuid, $string );
     return $string;
}

sub queueshow {
    my $c = shift;
    my $res = $c->queue->all() || [];
    $res = [ map { decode_json $_ } @$res ];
    #warn "# res all in queue => ", Dumper $res;
    #$c->stash( data => $res );

    $c->render( list => $res );#
}

sub list {
    my $c = shift;
    my $params      = $c->req->params->to_hash;
    my $page        = $params->{ page }        || 1;
    my $page_length = $params->{ page_length } || ITEMS_IN_PAGE;

    my ( $items_count ) = $c->dbh->selectrow_array(
        'SELECT count(*) FROM message.items',
    );
    #warn "# items_count all in db => ", $c->dumper( $items_count );

    my $pagging = $c->pager->calculate( $page, $page_length, $items_count );

    my $res = $c->dbh->selectall_arrayref(
        'SELECT * FROM message.items ORDER BY created DESC LIMIT ? OFFSET ?',
        { Slice => {} },
        $pagging->{ limit },
        $pagging->{ offset },
    );
    #warn "# res all in db => ", Dumper $res;

    $c->render(
        list    => $res,
        pagging => $pagging,
    );#
}

sub list_ajax {
    my $c = shift;
    my $params      = $c->req->params->to_hash;
    my $page        = $params->{ page }        // 1;
    my $page_length = $params->{ page_length } || ITEMS_IN_PAGE;

    my ( $items_count ) = $c->dbh->selectrow_array(
        'SELECT count(*) FROM message.items',
    );
    #warn "# page[$page] items_count all in db => ", $c->dumper( $items_count );

    my $pagging = $c->pager->calculate( $page, $page_length, $items_count );
    if ( $page > $pagging->{ page_last_redirect } ) {
        #warn "# page_last redirect_to => ", $pagging->{ page_last_redirect };
        $c->redirect_to('/notifs?page='. $pagging->{ page_last_redirect });
    }
    elsif ( $page < $pagging->{ page_first_redirect } ) {
        #warn "# page_first redirect_to => ", $pagging->{ page_first_redirect };
        $c->redirect_to('/notifs?page='. $pagging->{ page_first_redirect });
    }
    $c->render;
}

sub list_part_ajax {
    my $c = shift;
    my $params      = $c->req->params->to_hash;
    my $page        = $params->{ page }        || 1;
    my $page_length = $params->{ page_length } || ITEMS_IN_PAGE;

    my ( $items_count ) = $c->dbh->selectrow_array(
        'SELECT count(*) FROM message.items',
    );
    #warn "# page[$page] items_count all in db => ", $c->dumper( $items_count );

    my $pagging = $c->pager->calculate( $page, $page_length, $items_count );

    my $res = $c->dbh->selectall_arrayref(
        'SELECT * FROM message.items ORDER BY created DESC LIMIT ? OFFSET ?',
        { Slice => {} },
        $pagging->{ limit },
        $pagging->{ offset },
    );
    #warn "# res all in db => ", Dumper $res;

    $c->render(
        json => {
            success => 1,
            params  => $c->req->params->to_hash,
            data    => {
                list    => $res,
                pagging => $pagging,
            }
        }
    );
}

sub item {
    my $c = shift;
    my $params = $c->req->params->to_hash;
    my $stash  = $c->stash;
    my $id = $stash->{ id };
    #warn $c->dumper( $id );

    my $res = $c->dbh->selectrow_hashref(
        'SELECT * FROM message.items WHERE id = ?',
        { Slice => {} },
        $id,
    );
    #warn "# res one in db => ", $c->dumper( $res );

    $res->{ message } =~ s#\n#<br />#msg;
    $c->render( item => $res );
}

1;
