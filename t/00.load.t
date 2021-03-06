
use strict;
use warnings;

use lib 'lib';

use English qw/ -no_match_vars /;
use Test::More;

if ( $OSNAME =~ /cygwin|win32|windows/i ) {
    plan skip_all => "no windows support";
};

use_ok('Mail::Toaster');
use_ok('Mail::Toaster::DNS');
use_ok('Mail::Toaster::Ezmlm');
use_ok('Mail::Toaster::Logs');
use_ok('Mail::Toaster::Qmail');
use_ok('Mail::Toaster::Utility');
use_ok('Mail::Toaster::Darwin');
use_ok('Mail::Toaster::FreeBSD');
use_ok('Mail::Toaster::Mysql');
use_ok('Mail::Toaster::Setup');

diag( "Testing Mail::Toaster $Mail::Toaster::VERSION, Perl $], $^X" );

done_testing();
