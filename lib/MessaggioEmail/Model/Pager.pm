package MessaggioEmail::Model::Pager;

use strict;
use warnings;
use Data::Dumper qw(Dumper);

sub new {
    my $class = shift;
    bless {}, $class;
}

sub calculate {
    my $self = shift;
    my ( $page_current, $page_length, $items_count ) = @_;
    warn "# $page_current, $page_length, $items_count";
    my %pagging = ();

    $pagging{ pages_number  } = int( $items_count / $page_length );
    warn "# pages_number $pagging{ pages_number }\n";
    $pagging{ pages_number  }++ if $items_count % $page_length;
    warn "# pages_number $pagging{ pages_number }\n";

    $pagging{ page_first    } = 1;
    $pagging{ page_last     } = $pagging{ pages_number };
    $pagging{ page_current  } = $page_current;
    $pagging{ page_next     } = $page_current + 1;
    $pagging{ page_previous } = $page_current - 1;

    $pagging{ page_next     } = undef if $pagging{ page_next } > $pagging{ page_last };
    $pagging{ page_next     } = undef if $pagging{ page_next } == $pagging{ page_last };
    $pagging{ page_previous } = undef if $pagging{ page_previous } <= 0;
    $pagging{ page_previous } = undef if $pagging{ page_previous } == $pagging{ page_first };

    $pagging{ page_next     } = undef if $pagging{ page_last  } == $page_current;
    $pagging{ page_previous } = undef if $pagging{ page_first } == $page_current;
    $pagging{ page_first    } = undef if $pagging{ page_first } == $page_current;
    $pagging{ page_last     } = undef if $pagging{ page_last  } == $page_current;


    $pagging{ offset } = ( $page_current - 1 ) * $page_length;
    $pagging{ limit  } = $page_length;

    warn Dumper( \%pagging );

    return \%pagging;
}


1;