function send_message() {
    $( '#main_form :submit').attr('disabled', true );// блокировка от повторных нажатий
    var data = {
        sender:  $( '#main_form input[name=sender]').val(),
        to:      $( '#main_form input[name=to]').val(),
        subject: $( '#main_form input[name=subject]').val(),
        message: $( '#main_form textarea[name=message]').val()
    };
    console.log(data);

    //var j = 0;
    //for ( var i = 0; i < fields_need.length; i++ ) {
    //    console.log( fields_need[i] +' '+ data[ fields_need[i] ] );
    //    if ( !data[ fields_need[i] ] ) {
    //        j++;
    //    }
    //}
    if ( submit_toggle() ) {// надо дочинить
        $( '#main_form :submit').attr('disabled', false );// выключение блокировки от повторных нажатий
        //return false;
    }
    //return false;
    console.log(3);

    $.ajax({
        method: "POST",
        url: "/notifs",
        data: data
    }).done(function( msg ) {
        console.log( "Data Saved: " + msg );
        $( '#main_form :submit').attr('disabled', false );
    }).fail(function( jqXHR, textStatus ) {
        alert( "Request failed: " + textStatus );
        $( '#main_form :submit').attr('disabled', false );
    });
    console.log("After ajax");
    return false
}

function submit_toggle() {
    var j = 0;
    for ( var i = 0; i < fields_need.length; i++ ) {
        var value_f = $( '#main_form *[name='+ fields_need[i] +']').val();
        if ( !value_f ) {
            j++;
        }
    }
    if ( !j ) {
        $( '#main_form :submit').attr('disabled', false );
        return true;
    }
    else {
        $( '#main_form :submit').attr('disabled', true );
        return false;
    }
}

var fields_need = ['to','subject','message'];
$(function() {
    $('#main_form :submit').attr('disabled', true );
    $('#main_form').bind('submit', {}, send_message);
    jQuery.each( fields_need, function( index, value ) {
        $( '#main_form *[name='+ value +']').bind('keyup', function() {
            if ( !$( this ).val() ) {
                $( this ).parent().addClass('is-invalid');
            }
            else {
                $( this ).parent().removeClass('is-invalid');
            }
            submit_toggle();
        });
    });
    submit_toggle();
});
