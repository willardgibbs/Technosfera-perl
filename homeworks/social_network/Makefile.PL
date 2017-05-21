use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Local::SocialNetwork',
    EXE_FILES       => ['bin/load_base.pl'],
    VERSION_FROM    => 'lib/Local/SocialNetwork.pm'
);
