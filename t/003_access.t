# -*- perl -*-



use Test::More qw(no_plan);

BEGIN { use_ok( 'Data::Bucket' ); }

my @data = ('lars', 'larry', 'daniel', 'ronny', 'randy', 'rick', 'ruby');


my $bucket = Data::Bucket->index (data => \@data);
isa_ok ($bucket, 'Data::Bucket');

use Data::Dumper;

for my $search ( qw(randal larry damian) ) {
    warn "bucket for $search: " . Dumper [ $bucket->based_on($search) ] ;
}



