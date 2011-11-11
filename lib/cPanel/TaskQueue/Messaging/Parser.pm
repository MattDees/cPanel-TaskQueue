package cPanel::TaskQueue::Messaging::Parser;

use File::ReadBackwards ();

#instantiate a new parsing object
sub new {
    my ($class, $dir, $id) = @_;
    if ( !-d $dir ) {
        return undef, 'Msg directory does not exist';
    }
    my $id_file = "${dir}/${id}_msg";
    if ( !-e $id_file ) {
        return undef, 'Id file does not exist';
    }

    open $msg_fh, '<', $id_file || return undef, "unable to open id file ${id_file}, ";
    my $call_line = readline $msg_fh;
    chomp $call_line if $call_line =~ m/\n$/;
    
    my $end_of_call_tell = tell $msg_fh;
    my $self = bless {
        'id' => $id,
        '_dir' => $dir,
        '_file' => $id_file,
        '_msg_fh' => $msg_fh,
        'call_line' => $call_line,
        '_end_of_call_tell' => $end_of_call_tell,
    }, $class;

    return $self;
}


# Stub, This should be overwritten by something more intelligent
sub get_call_info {
    my ($self) = @_;
    my ($time, undef, $command ) = split(':', $self->{'call_line'}, 3);
    return {
        'start_time' => $time,
        'parameters' => $command,
    };
}

# stub, should be overwritten by something more intelligent
sub get_last_msgs_of_type {
    my ($self, @types) = @_;
    return $self->_get_last_msgs_of_type(@types);
}

sub _get_last_msgs_of_type {
    my ( $self, @types ) = @_;
    my $rb_fh = File::ReadBackwards->new( $self->{'_msg_fh'} );
    my %res;
    while ( my $line = $rb_fh->readline() ) {
        my ( undef, $type, undef ) = split(':', $line, 3);
        
        # Add the type to the result hash
        if ( ( grep /\Q$type\E/, @types ) && !exists $res{$type} ) {
            $res{$type} = $line;
        }
        
        # If we have all our types detected, stop processing.
        if ( keys %res == length @types ) {
            last;
        }
        
    }
    return wantarray ? %res : \%res;
}

# stub, should be overwritten by something more intelligent
sub get_last_number_of_msgs {
    my ( $self, $num_of_lines ) = @_;
    return $self->_get_last_number_of_msgs($num_of_lines);
}

sub _get_last_number_of_msgs {
    my ($self, $num_of_lines) = @_;
    my $rb_fh = File::ReadBackwards->new( $self->{'_msg_fh'} );
    my @res;
    for ( my $cnt = 0; $cnt < $num_of_lines; $cnt++) {
        unshift @res, $rb_fh->readline();
    }
    return wantarray ? @res : \@res;
}

sub _read_msg_file {
    my ($self) = @_;
    sysseek( $self->{'_msg_fh'}, 0, $self->{'_end_of_call_tell'} )
}

1;