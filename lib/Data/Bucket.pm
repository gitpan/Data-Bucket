package Data::Bucket;
use strict;

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.03';
    @ISA         = qw(Exporter);
    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}


=head1 NAME

Data::Bucket - indexed data store (bucket hashing)

=head1 SYNOPSIS

  use base qw(Data::Bucket) ;

  # default storage scheme stores things based on first character of data
  # we overwrite it in our sub-class
  # If we return an array-ref, then the data item is stored in each 
  # bucket as opposed to a single.
  sub compute_record_index {
    my ($self, $data) = @_;
    substr(0, 2, $data); 
  } 

  open S, $file_to_be_searched or die $! ; 

  my $bucket = __PACKAGE__->index(<S>) ;

  open I, $file_with_queries or die $! ;

  for my $line (<I>) {
    my $search_candidates = $bucket->based_on($line);
    my @score = sort map { fuzzy_match($line, $_) } @{$search_candidates} ;
  }


=head2 An example in which a single datum is dumped to multiple buckets

 sub compute_record_index {
    my ($self, $data) = @_;

    return undef unless $data;

    warn "<data>$data</data>";
    my @words = split /\s+/, $data ;
    my $min = min($#words, 1);
    my @index = map { substr($_, 0, 1) } @words[0..$min];
    \@index;
 } 


 for my $search ( qw(oh the so draw apple) ) {
    my @b = $bucket->based_on($search);
    # do something which each bucket and $search
 }


=head1 DESCRIPTION

Oftentimes you have one file that is a lookup file and another file that
contains things you will look up. Iterating through all of the lookup file
for the thing you want to lookup can sometimes be avoided if something 
about the similarity of the data sets is known in advance.

For instance, if you know that the first character of records which will match
will be exactly the same, then you can partition the lookup file into
26 "buckets" and reduce your search by 26-fold (assuming an equal number of 
members of each bucket). 

While this is rather simple to hand-code, I desired an API for this so that
my code was more DWIS than DWIM. And also so that the bucket routine could
be swapped in and out easily.

=head2 RELATED WORK

I developed this module while doing some Record Linkage. Record Linkage is
the art and science of joining data records using deterministic and
probabalistic approaches. The indexing method here is as simple and naive
as they get. A nice Python package with several indexing methods is
L<http://datamining.anu.edu.au/projects/|FEBRL>. They discuss the science
of data indexing and more. It's a great read.

=head1 USAGE

The usage is pretty simple. You simply pass an array of data to the
constructor and it uses the C<compute_record_index()> function of the 
C<Data::Bucket> (sub)class to partition your data set. 

One this is done, you simply request the bucket based on your input data
and it again uses the C<compute_record_index()> function to find the right
bucket and return it to you.


If C<compute_record_index()> returns an array ref, then the data is
stored in a bucket for each member of the array ref. Likewise, the call
to C<< $bucket->based_on >> will return an array ref if multiple buckets
are computed for the data.



=head1 METHODS

=head2 index

 Usage     : my $bucket = Data::Bucket->index(data => strings, %other);
 Purpose   : Build a data structure with @strings partitioned into buckets
 Returns   : An object.
 Argument  : A list of data compatible with the compute_index() function

=cut

sub index
{
    my ($class, %parm) = @_;

    exists $parm{data} or die "Data must be passed for indexing" ;
    ref $parm{data} eq 'ARRAY' or die 'You must pass an array ref';

    my $self = bless (\%parm, ref ($class) || $class);

    $self->bucket_hash;

    return $self;
}

=head2 bucket_hash

 Usage     : Called internally by index()
 Purpose   : Partition $self->{data} by repeated calls 
   to $self->compute_record_index
 Returns   : Nothing
 Argument  : None.

=cut

sub bucket_hash
{
    my ($self) = @_;

    for my $data (@{$self->{data}}) {
	my $index = $self->compute_record_index($data);

	my @index = ref $index eq 'ARRAY' ? @$index : ($index) ;
	for (@index) {
	    push @{ $self->{bucket}{$_} } , $data ;
	}
    }

    return $self;
}

=head2 based_on

 Usage     : $bucket->based_on($input_data);
 Purpose   : Return the bucket of data to search relevant to your input data.
   NOTE: it returns either a scalar or an array based on whehter
         compute_record_index returns a scalar or array ref
 Returns   : an array reference
 Argument  : the input data, which will find a bucket 
  via compute_record_index

=cut

sub based_on
{
    my ($self, $data) = @_;

    my @ret;

    my $index = $self->compute_record_index($data);
    my @index = ref $index eq 'ARRAY' ? @$index : ($index) ;
    for (@index) {
	push @ret, $self->{bucket}{$_};
    }
    @ret;
}


=head2 compute_record_index

 Usage     : Internal use by index_data()
 Purpose   : Compute the index for a particular record. Subclassing this 
    method can change the indexing.
    NOTE: you may return either a scalar or an array ref.
 Returns   : Nothing
 Argument  : a data item

The default function simply returns C<substr(0, 1, $data)> which is a
naive binning of the data into 26 parts, with A, E, I, O, and U certain
to bulge!

=cut

#################### subroutine header end ####################


sub compute_record_index
{
    my ($class, $data) = @_;

    substr($data, 0, 1) ;
}


#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!




=head1 BUGS

Bugs? Are you kidding?!

=head1 SUPPORT



=head1 AUTHOR

    Terrence M. Brannon
    CPAN ID: TBONE
    metaperl computation is about meta-computing in perl
    tbone@cpan.org
    http://www.metaperl.com

Many thanks to Matthew Trout.

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

