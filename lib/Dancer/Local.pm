package Dancer::Local;

use 5.10.0;

use strict;
use warnings;

use File::ShareDir 'dist_dir';
use File::HomeDir;
use File::Copy::Recursive qw/ dircopy /;

# if DANCER_APPDIR is set, use that
# check if already installed in DANCER_LOCALDIR,
# if not, do it


sub import {
    my( $self, $dist ) = @_;

    return if $ENV{DANCER_APPDIR};

    my $local_copy 
        = $ENV{DANCER_APPDIR}
        = File::HomeDir->my_dist_data($dist);

    unless ( $local_copy ) {
        $local_copy = File::HomeDir->my_dist_data($dist,{create=>1});

        print "copying $dist app files to $local_copy...\n";

        dircopy( dist_dir($dist) => $local_copy );
    }

    if ( open my $fh, "$local_copy/REMOVE_ME" ) {
        warn $_ while <$fh>;

        die "\n*** review the configuration files in '$local_copy'\n",
            "*** delete '$local_copy/REMOVE_ME',\n",
            "*** and run $0 again\n";
    }

    return warn "running $dist from $local_copy";
}

1;


