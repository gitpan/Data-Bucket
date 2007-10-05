# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More qw(no_plan);

BEGIN { use_ok( 'Data::Bucket' ); }

my @data = ('aaaa', 'cddd', 'ceee', 'cccc', 'tttt', 'abbb', 'rrrrr');


eval { 
    my $bucket = Data::Bucket->index;
};
like ($@, qr/data must be passed for indexing/i, 'parm check - no data');

eval {
    my $bucket = Data::Bucket->index (data => @data);
};
like ($@, qr/must pass an array ref/i, 'parm check - bad data');

my $bucket = Data::Bucket->index (data => \@data);
isa_ok ($bucket, 'Data::Bucket');


use Data::Dumper;
warn Dumper $bucket->{bucket};
