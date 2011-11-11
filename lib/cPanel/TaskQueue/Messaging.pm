package cPanel::TaskQueue::Messaging;

use strict;
use Carp ();

# use of JSON may change in later revisions
use JSON::Syck ();

# Set up the messaging file.
# This is the only function within this module that should be run w/o an object.
#SERIALIZATION
sub initiate_msg_file {
    my ( $dir, $task ) = @_;

    my $uuid     = $task->{_uuid};
    my $msg_file = "$dir/${uuid}_msgs";

    my $initial_data = time() . ':' . 'info' . ':' . $task->{'_command'};
    if ( -e $msg_file ) {
        Carp::croak("The TaskQueue message file $msg_file already exists, cannot initialize message queue");
    }

    # TODO: beef up validation that this worked.
    open( my $msg_fh, '>', $msg_file );
    print ${msg_fh} $initial_data . "\n";
    close $msg_fh;
}

#SERIALIZATION
sub finalize_msg_queue {
    my ( $dir, $msg, $task ) = @_;

    my $uuid     = $task->{_uuid};
    
    $msg      = time() . ':info:' . $msg;
    my $msg_file = "$dir/" . $task->{'_uuid'};
    open( my $msg_fh, '>>', $msg_file );
    print ${msg_fh} $msg;
    close $msg_fh;
}

# validate_message_format()
# This subroutine will return a boolean value based on whether a msg_ref is the correct format.
# param: $msg_ref
# returns: boolean
sub validate_message_format {

    # TODO: actually implement this
    return 1;
}

sub new {
    my ( $class, $dir, $id ) = @_;
    my $msg_file = "$dir/${id}_msgs";
    if ( !-e $msg_file ) {
        Carp::croak("Provided message file $msg_file does not exist");
        return;
    }

    if ( !validate_message_format($msg_file) ) {

        #FAIL
    }

    return bless {
        'msg_file' => $msg_file,
        'id'       => $id,
        'msg_dir'  => $dir,
    }, $class;
}

sub add_msg {
    my ( $self, $msg_ref ) = @_;
    if ( !defined $msg_ref->{'type'} || !defined $msg_ref->{'msg'} ) {

        #TODO: THROW WARNING HERE
        return;
    }

    #SERIALIZATION
    my $msg = time() . ':' . $msg_ref->{'type'} . ':' . $msg_ref->{'msg'};
    $self->update_msg_file();
}

sub finish_msging {
    my ($self) = @_;
    my $msg_ref = {
        'type' => 'info',
        'msg'  => 'Task Completed'
    };
    $self->add_msg($msg_ref);
}

sub update_msg_file {
    my ( $self, $msg, $close_fh ) = @_;
    if ( !defined $self->{'msg_fh'} ) {
        open $self->{'msg_fh'}, '>>', $self->{'msg_file'};
    }
    print {$self->{'msg_fh'}} $msg . "\n";
    if ($close_fh) {
        close $self->{'msg_fh'};
    }
}

1;
