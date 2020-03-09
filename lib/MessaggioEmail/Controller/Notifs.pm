package MessaggioEmail::Controller::Notifs;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(decode_json encode_json);
use Data::Dumper qw(Dumper);

# This action will render a template
sub welcome {}
sub sendto {
    my $self = shift;
    my @fields_all  = qw( sender to subject message );
    my @fields_need = qw(        to subject message );
    my $data = { map { $_ => $self->param( $_ ) } @fields_all };
    warn "# notifs data ", Dumper $data;

    unless ( grep { !$data->{ $_ } } @fields_need ) {
        $self->render(json => {success => 0, params => $self->req->params->to_hash, error => { str => 'NOT_ALL_FIELDS_OF_NEED_WAS_FILLED'}});
    }
    warn "# notifs 1";

    my $res = $self->queue->add( encode_json $data );
    warn "# notifs queue->add res", Dumper $res;

    # Render template "example/welcome.html.ep" with message
    $self->render(json => {success => 1, params => $self->req->params->to_hash, data => { result => $res,str => 'DATA_INTO_QUEUE_ADDED'}});
}

sub queueshow {
    my $self = shift;
    my $res = $self->queue->all() || [];
    $res = [ map { decode_json $_ } @$res ];
    warn "# res all in queue => ", Dumper $res;
    #$self->stash( data => $res );
    $self->render( list => $res );#
}
sub list {}
sub item {}

1;
