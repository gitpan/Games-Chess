use ExtUtils::MakeMaker;

WriteMakefile
  (
   NAME		=> 'Games::Chess',
   VERSION_FROM	=> 'Chess.pm',
   PMLIBDIRS    => [ 'Chess' ],
   dist         => { COMPRESS => 'gzip', SUFFIX => 'gz' }
  );
