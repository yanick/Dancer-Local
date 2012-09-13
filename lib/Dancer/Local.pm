package Dancer::Local;
# ABSTRACT: allows Dancer applications to be installed like modules

use 5.10.0;

use strict;
use warnings;

use File::ShareDir 'dist_dir';
use File::HomeDir;
use File::Copy::Recursive qw/ dircopy /;
use File::Path qw/ make_path /;
use List::MoreUtils qw/ after_incl /;

sub import {
    my( $self, $dist ) = @_;

    my $appdir;

    if ( my @to_install = after_incl { $_ eq '--install' } @ARGV ) {
        make_path( $to_install[1] ) if defined $to_install[1];

        $appdir = $to_install[1] // '.';

        dircopy( dist_dir($dist) => $appdir );

        say "installed shared file for '$dist' in '$appdir'";
    }
    else {
        no warnings 'uninitialized';

        $appdir = $ENV{DANCER_APPDIR} 
            || ( '.' x -f 'config.yml' )
            || File::HomeDir->my_dist_data($dist) 
            || create_local_copy($dist);
    }

    $ENV{DANCER_APPDIR} = $appdir;

    if ( open my $fh, "$appdir/REMOVE_ME" ) {
        say "\n", <$fh>, "\n", 
            "*** review the configuration files in '$appdir'\n",
            "*** delete '$appdir/REMOVE_ME',\n",
            "*** and run $0 again\n";

        exit;
    }

    say "running $dist from $appdir...";
}

sub create_local_copy {
    my $dist = shift;

    my $local_copy = File::HomeDir->my_dist_data($dist,{create=>1});

    print "copying $dist app files to $local_copy...\n";

    dircopy( dist_dir($dist) => $local_copy );

    return $local_copy;
}

1;


