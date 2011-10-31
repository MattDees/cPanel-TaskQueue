package cPanel::TaskQueue::MessagingProcessor;

# This class is very specifically designed to be a processor for handling API calls.

use strict;
#use warnings;
use base 'cPanel::TaskQueue::ChildProcessor';
use cPanel::TaskQueue::Messaging    ();

{
    my $dir = '/var/cpanel/taskqueue/msgs';
    sub pre_queue {
        my ($self, $task) = @_;
        
        cPanel::TaskQueue::Messaging::initialize_msg_queue($dir, $task);
    }
    sub pre_unqueue {
        my ($self, $msg, $task) = @_;
        cPanel::TaskQueue::Messaging::finalize_msg_queue($dir, $msg, $task);
    }
}

1;