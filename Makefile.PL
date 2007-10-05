

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Data::Bucket',
    VERSION_FROM => 'lib/Data/Bucket.pm', # finds \$VERSION
    AUTHOR       => 'Terrence M. Brannon (tbone@cpan.org)',
    ABSTRACT     => 'indexed data store (bucket hashing)',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
