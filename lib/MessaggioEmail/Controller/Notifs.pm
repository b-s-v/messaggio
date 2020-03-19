package MessaggioEmail::Controller::Notifs;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(decode_json encode_json);
use Data::Dumper qw(Dumper);

use constant {
    ITEMS_IN_PAGE => 10,
};

# This action will render a template
sub welcome {}
sub sendto {
    my $c = shift;
    my @fields_all  = qw( sender to subject message );
    my @fields_need = qw(        to subject message );
    my $data = { map { $_ => $c->param( $_ ) } @fields_all };
    warn "# notifs data ", Dumper $data;

    unless ( grep { !$data->{ $_ } } @fields_need ) {
        $c->render(json => {success => 0, params => $c->req->params->to_hash, error => { str => 'NOT_ALL_FIELDS_OF_NEED_WAS_FILLED'}});
    }
    warn "# notifs 1";

    my $res = $c->queue->add( encode_json $data );
    warn "# notifs queue->add res", Dumper $res;

    # Render template "example/welcome.html.ep" with message
    $c->render(json => {success => 1, params => $c->req->params->to_hash, data => { result => $res,str => 'DATA_INTO_QUEUE_ADDED'}});
}

sub queueshow {
    my $c = shift;
    my $res = $c->queue->all() || [];
    $res = [ map { decode_json $_ } @$res ];
    warn "# res all in queue => ", Dumper $res;
    #$c->stash( data => $res );
    $c->render( list => $res );#
}

sub list {
    my $c = shift;
    my $params      = $c->req->params->to_hash;
    my $page        = $params->{ page } || 1;
    my $page_length = $params->{ page_length } || ITEMS_IN_PAGE;

    my ( $items_count ) = $c->dbh->selectrow_array(
        'SELECT count(*) FROM message.items',
    );
    warn "# items_count all in db => ", $c->dumper( $items_count );

    my $pagging = $c->pager->calculate( $page, $page_length, $items_count );

    my $res = $c->dbh->selectall_arrayref(
        'SELECT * FROM message.items ORDER BY created LIMIT ? OFFSET ?',
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

sub item {}

1;
