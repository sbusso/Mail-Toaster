
use strict;
use warnings;

use Cwd;
use Test::More;

use lib 'lib';

use_ok('Mail::Toaster');
use_ok('Mail::Toaster::Setup');

my $debug = 0;
my %test_params = ( fatal => 0, debug => $debug );

my $toaster = Mail::Toaster->new(debug=>0);
my $util = $toaster->get_util();
my $conf = $toaster->get_config();

# basic OO mechanism
my $setup = Mail::Toaster::Setup->new( toaster => $toaster, conf => $conf );
ok( defined $setup, 'new Mail::Toaster::Setup object)' );
ok( $setup->isa('Mail::Toaster::Setup'), 'setup object class' );
# 6 tests completed

my $initial_working_directory = cwd;
my @subs_to_test = qw/ apache autorespond clamav courier_imap cronolog
  daemontools djbdns dovecot expat ezmlm lighttpd munin mysql 
  openssl_conf qmailadmin razor roundcube simscan spamassassin 
  squirrelmail sqwebmail vpopmail vqadmin 
/;

# 3 tests per sub
foreach my $sub (@subs_to_test) {

    my $install_sub = "install_$sub";
    my $before      = $conf->{$install_sub};    # preserve initial settings

    $conf->{$install_sub} = 1;                  # enable install in $conf

    # test to insure params and initial tests are passed
    ok(  $setup->$sub( test_ok => 1, %test_params), $sub );
    ok( !$setup->$sub( test_ok => 0, %test_params), $sub );

    $conf->{$install_sub} = 0;                  # disable install

    # and then make sure it refuses to install
    ok( !$setup->$sub( %test_params ), $sub );

    # set $conf->install_sub back to its initial state
    $conf->{$install_sub} = $before;
}

# config
ok( $setup->config( test_ok => 1, %test_params ), 'config' );
ok( !$setup->config( test_ok => 0, %test_params ), 'config' );

# dependencies
ok( $setup->dependencies( test_ok => 1 ), 'dependencies' );
ok( !$setup->dependencies( test_ok => 0, %test_params), 'dependencies' );

#ok ( $setup->dependencies( debug=>1 ), 'dependencies' );

# filtering
ok( $setup->filtering( test_ok => 1 ), 'filtering' );
ok( !$setup->filtering( test_ok => 0, %test_params ), 'filtering' );

# is_newer
    ok ($setup->is_newer( min=>"5.3.30", cur=>"5.3.31", debug=>0), 'is_newer third');
    ok ($setup->is_newer( min=>"5.3.30", cur=>"5.4.30", debug=>0), 'is_newer second');
    ok ($setup->is_newer( min=>"5.3.30", cur=>"6.3.30", debug=>0), 'is_newer first');
    ok (! $setup->is_newer( min=>"5.3.30", cur=>"5.3.29", debug=>0), 'is_newer third neg');
    ok (! $setup->is_newer( min=>"5.3.30", cur=>"5.2.30", debug=>0), 'is_newer second neg');
    ok (! $setup->is_newer( min=>"5.3.30", cur=>"4.3.30", debug=>0), 'is_newer first neg');

# nictool
ok( $setup->nictool( test_ok => 1 ), 'nictool' );
ok( !$setup->nictool( test_ok => 0, debug => 1, fatal=>0 ), 'nictool' );

# set this back to where we started so subsequent testing scripts work
chdir($initial_working_directory);

done_testing();
