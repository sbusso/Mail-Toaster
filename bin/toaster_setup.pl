#!/usr/bin/perl
use strict;
use warnings;

use English qw( -no_match_vars );
use Getopt::Long;
use Pod::Usage;

use lib 'lib';
use Mail::Toaster          5.35; 
use Mail::Toaster::Apache  5.35; 
use Mail::Toaster::FreeBSD 5.35; 
use Mail::Toaster::Qmail   5.35; 
use Mail::Toaster::Setup   5.35; 
use Mail::Toaster::Utility 5.35; 

$OUTPUT_AUTOFLUSH++;

my %command_line_options = (
	'secti=s'   => \my $section,
	'verbose'   => \my $debug,
);
GetOptions (%command_line_options);

$debug = 0 unless defined $debug;

my $toaster = Mail::Toaster->new( debug => $debug );
my $apache  = Mail::Toaster::Apache->new( toaster =>$toaster );
my $freebsd = Mail::Toaster::FreeBSD->new( toaster => $toaster );
my $qmail   = Mail::Toaster::Qmail->new( toaster => $toaster );
my $util = $toaster->get_util;
my $conf = $toaster->get_config;

print "verbose mode enabled\n\n" if $debug;

if ( ! $section ) { 
    pod2usage( { -verbose=>0, }); 
    die "You must choose a section!\n"; 
};

# these sections do not require root privs to run
my $root_agnostic = { help => 1, docs => 1, test2 => 1, };

# everything else requires root
if ( $UID != 0 && !$root_agnostic->{$section} ) { 
	die "Thou shalt have root to proceed!\n"; 
};

if ( $debug ) {
    $conf->{'toaster_debug'} = 1;
    $toaster->{debug} = 1;
}
else {
    $toaster->{debug} = 0;
};

my $setup = Mail::Toaster::Setup->new(toaster=>$toaster, conf=>$conf);

  $section eq 'pre'        ? $setup->dependencies      ()
: $section eq 'cpan'       ? $setup->cpan              ()
: $section eq 'docs'       ? $setup->docs              ()
: $section eq 'help'       ? pod2usage                 ( {-verbose=>1 } )
: $section eq 'config'     ? $setup->config            ()
: $section eq 'ssl'        ? $setup->openssl_conf      ()

#  port management on FreeBSD and Darwin
: $section eq 'ports'      ? $setup->ports            ()
: $section eq 'portmaster' ? $setup->portmaster       ()

#  Standard daemons & utilities
: $section eq 'mysql'      ? $setup->mysql            ()
: $section eq 'lighttpd'   ? $setup->lighttpd         ()
: $section eq 'apache'     ? $setup->apache           ()
: $section eq 'apachessl'  ? $setup->apache(ver=>'ssl' )
: $section eq 'cronolog'   ? $setup->cronolog         ()

#  Qmail & related
: $section eq 'ucspi'      ? $setup->ucspi_tcp        ()
: $section eq 'daemontools'? $setup->daemontools      ()
: $section eq 'ezmlm'      ? $setup->ezmlm            ()
: $section eq 'autorespond'? $setup->autorespond      ()
: $section eq 'vpopmail'   ? $setup->vpopmail         ()
: $section eq 'vpeconfig'  ? $setup->vpopmail_etc     ()
: $section eq 'vpopmysql'  ? $setup->vpopmail_mysql_privs()
: $section eq 'vqadmin'    ? $setup->vqadmin          ()
: $section eq 'qmail'      ? $qmail->install_qmail    (debug=>$debug )
: $section eq 'qmailconf'  ? $qmail->config           (debug=>$debug )
: $section eq 'netqmail'   ? $qmail->netqmail         (debug=>$debug )
: $section eq 'netqmailmac'? $qmail->netqmail_virgin  (debug=>$debug )
: $section eq 'djbdns'     ? $setup->djbdns           ()

# mail servers
: $section eq 'dovecot'    ? $setup->dovecot          ()
: $section eq 'courier'    ? $setup->courier_imap     ()
: $section eq 'courierconf'? $setup->courier_config   ()

#  Web Mail & Admin interfaces
: $section eq 'qmailadmin'  ? $setup->qmailadmin       ()
: $section eq 'sqwebmail'   ? $setup->sqwebmail        ()
: $section eq 'squirrelmail'? $setup->squirrelmail     ()
: $section eq 'roundcube'   ? $setup->roundcube        ()

#  Mail Filtering
: $section eq 'filter'      ? $setup->filtering        ( )
: $section eq 'razor'       ? $setup->razor            ( )
: $section eq 'maildrop'    ? $setup->maildrop         ( )
: $section eq 'clamav'      ? $setup->clamav           ( )
: $section eq 'simscan'     ? $setup->simscan          ( )
: $section eq 'simconf'     ? $setup->simscan_conf     ( )
: $section eq 'simtest'     ? $setup->simscan_test     ( )
: $section eq 'spamassassin'? $setup->spamassassin     ( )
: $section eq 'allspam'     ? $setup->enable_all_spam  ( )

#  Logs, Statistics & Monitoring
: $section eq 'maillogs'    ? $setup->maillogs         ( )
: $section eq 'socklog'     ? $setup->socklog          ( )
: $section eq 'isoqlog'     ? $setup->isoqlog          ( )
: $section eq 'supervise'   ? $setup->supervise        ( )
: $section eq 'munin'       ? $setup->munin            ( )

# test targets
: $section eq 'test'        ? $setup->test             ( )
: $section eq 'filtertest'  ? $setup->filtering_test   ( )
: $section eq 'authtest'    ? $setup->test_auth        ( )
: $section eq 'proctest'    ? $toaster->check_processes (debug=>$debug)
: $section eq 'imap'        ? $setup->imap_test_auth   ( )
: $section eq 'pop3'        ? $setup->pop3_test_auth   ( )
: $section eq 'smtp'        ? $setup->smtp_test_auth   ( )
: $section eq 'rbltest'     ? $setup->test_rbls        ( )
: $section eq 'test2'       ? exit 0

#  misc 
: $section eq 'toaster'     ? $util->mail_toaster      ( )
: $section eq 'nictool'     ? $setup->nictool          ( )
: $section eq 'webmail'     ? $setup->webmail          ( )
: $section eq 'all'         ? all()

# deprecated
: $section eq 'mattbundle'  ? $setup->mattbundle       ( )
: $section eq 'qss'         ? $setup->qs_stats         ( )
: $section eq 'logmonster'  ? $setup->logmonster       ( )
: $section eq 'mrm'         ? $setup->mrm              ( )
: $section eq 'phpmyadmin'  ? $setup->phpmyadmin       ()

: pod2usage( {-verbose=>1} );

sub all {
	$setup->config        ( );

    # re-initialize $conf with new settings. 
    $conf = $util->parse_config( "toaster-watcher.conf", debug => $debug );
    $toaster->{'debug'} = 1 if $debug;
    $conf->{'toaster_debug'} = 1 if $debug;
    $setup = Mail::Toaster::Setup->new(toaster=>$toaster, conf => $conf);

	$setup->dependencies  ( );
	$setup->openssl_conf  ( );
	$setup->ports         ( );
	$setup->mysql         ( ); 
	$setup->apache        ( );
	$setup->webmail       ( fatal=>0 );
	$setup->phpmyadmin    ( );
	$setup->ucspi_tcp     ( );
	$setup->ezmlm         ( );
	$setup->vpopmail      ( );
	$setup->maildrop      ( );
	$setup->vqadmin       ( );
	$setup->qmailadmin    ( );
	$qmail->netqmail      (debug=>$debug );
	$setup->courier_imap  ( );
	$setup->dovecot       ( );
	$setup->sqwebmail     ( );
	$setup->squirrelmail  ( );
	$setup->roundcube     ( );
	$setup->filtering     ( );
	$setup->maillogs      ( );
	$setup->supervise     ( );
	$setup->test          ( );
}

print "\n$0 script execution complete.\n";

exit 1;


__END__


=head1 NAME

toaster_setup.pl - runs various build and testing functions for Mail::Toaster


=head1 SYNOPSIS

toaster_setupl.pl is the front end to everything you need to turn a computer into a secure, full-featured, high-performance mail server.

   toaster_setup.pl -s <help> [-d]

      -s[ection] - see OPTIONS AND ARGUMENTS section for choices
      -d[ebug]   - enable verbose debugging


A really good place to start is:

   toaster_setupl.pl -s help | less


=head1 DESCRIPTION

The mail toaster is a collection of open-source software which provides a full-featured mail server running on FreeBSD, Mac OS X, and Linux. The system is built around the qmail mail transport agent, with many additions and modifications. Matt Simerson is the primary author and maintainer of the toaster. There is an active and friendly community of toaster owners which supports the toaster on a mailing list and web forum.

The toaster is built around qmail, a robust mail transfer agent by Daniel J. Bernstein, and vpopmail, a virtual domain manager by Inter7 systems. Matt keeps up with releases of the core software, evaluates them, decides when they are stable, and then integrates them into the toaster. Matt has also added several patches which add functionality to these core programs.

A complete set of instructions for building a mail toaster are on the toaster install page. There is a substantial amount of documentation available for the "Mail::Toaster" toaster. Much of it is also readable via "perldoc Mail::Toaster", and the subsequent pages. Don't forget to read the Install, Configure, and FAQ pages on the web site. If you still have questions, there is a Web Forum and mailing list. Both are browseable and searchable for your convenience. 

  
=head2 URLs

   http://mail-toaster.org/
   http://www.tnpi.net/internet/mail/toaster/
   

=head1 OPTIONS AND ARGUMENTS

  toaster_setup.pl -s <section> [-debug]

           help - print this usage screen
         config - initial configuration of toaster*.conf files
            pre - installs a list of programs and libraries other toaster components need

                    Standard Daemons & Utilities
          mysql - installs MySQL
     phpmyadmin - installs phpMyAdmin
         apache - installs Apache 
      apachessl - installs self signed SSL certs for Apache

                     Qmail and related tools
          ucspi - install ucspi-tcp w/MySQL patch
    daemontools - install daemontools
          ezmlm - install EzMLM idx
       vpopmail - installs vpopmail
      vpeconfig - configure ~vpopmail/etc/tcp.smtp
      vpopmysql - run the vpopmail MySQL grant and db create commands
        vqadmin - install vqadmin
          qmail - installs qmail with toaster patches
      qmailconf - configure various qmail control files
       netqmail - installs netqmail 
    netqmailmac - installs netqmail with no patches
         djbdns - install the djbdns program

        courier - installs courier imap & pop3 daemons
    courierconf - post install configure for courier

                   Web Mail and Admin interfaces
     qmailadmin - installs qmailadmin
      sqwebmail - installs sqwebmail (webmail app)
   squirrelmail - installs squirrelmail (webmail app)
      roundcube - installs Roundcube (webmail app)

                     Mail Filtering
         filter - installs SpamAssassin, ClamAV, DCC, razor, and more
          razor - installs the razor2 agents
       maildrop - installs maildrop and mailfilter
         clamav - installs just ClamAV
        simscan - install simscan
        simconf - configure simscan 
        simtest - run email tests to verify that simscan is working
   spamassassin - install and configure spamassassin
        allspam - activate spam filtering for all users

                  Logs, Statistics, and Monitoring
       maillogs - creates the mail logging directories
        socklog - installs socklog
        isoqlog - installs and configured isoqlog
      supervise - creates the directories to be used by svscan

           test - runs a complete test suite against your server
     filtertest - runs the simscan and qmail-scanner email scanner tests
       authtest - authenticates against pop, imap, and smtp servers
       proctest - check for processes that *should* be running
 imap|pop3|smtp - do authentication test for imap, pop3, or smtp-auth

        toaster - install Mail::Toaster
     logmonster - install Apache::Logmonster
        nictool - install nictool (http://www.nictool.com/)
            all - installs everything shown on the toaster INSTALL page

=head1 METHODS

=over 8

=item all

  toaster_setup.pl -s all


a special target that tries to build the entire Mail::Toaster without any interaction from you. Unlike other targets, it will keep right on going when it encounters an error, getting as much built as it possibly can. It is presumed that the administrator is logging the output for later review. I use this target primarily in testing.

=back

=head1 AUTHOR

Matt Simerson (matt@tnpi.net)


=head1 BUGS

None known. Report any to author, preferably via RT http://rt.cpan.org/Public/Bug/Report.html?Queue=Mail-Toaster

Patches welcome in "diff -u" format.


=head1 TODO

 Add -s dnscache section to install a DNS stub resolver
 Check if daemons are running before installs. - mostly done
 Turn entire process into a ./install_it_all script  - done


=head1 SEE ALSO

The following are all man/perldoc pages:

  Mail::Toaster::Conf
  toaster.conf 
  toaster-watcher.conf
  
  Mail::Toaster
  Mail::Toaster::Apache
  Mail::Toaster::CGI 
  Mail::Toaster::DNS
  Mail::Toaster::Darwin
  Mail::Toaster::Ezmlm
  Mail::Toaster::FreeBSD
  Mail::Toaster::Logs
  Mail::Toaster::Mysql
  Mail::Toaster::Qmail
  Mail::Toaster::Setup
  Mail::Toaster::Utility

  http://mail-toaster.org/
  http://mail-toaster.org/docs/
  http://mail-toaster.org/faq.shtml
  http://mail-toaster.org/changes.shtml


=cut
