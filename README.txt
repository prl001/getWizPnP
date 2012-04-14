Linux, Mac OSX, Cygwin & other Unix or Unix-like environments
=============================================================

getWizPnP is written in the scripting language Perl (http://www.perl.org/).
Perl is almost always part of the installation environment in
Unix-like environments. If it's not installed on a Linux system,
use the appropriate package manager to install it. On Cygwin, use
the Cygwin Setup installer and make sure "Interpreters, Perl" is
set for installation.

The Makefile should make it easy to install the tools on Unix-like
systems.

Install with
	make install

The PREFIX variable in the Makefile determines where the
installed files will go.
Set PREFIX (distributed as /usr/local) to the base directory where
you want to do the installation. Installs in $(PREFIX)/bin and
($PREFIX)/lib/perl.

Either edit PREFIX in the Makefile or use
	make PREFIX=/my/install/directory ...
to install somewhere else.

Uninstall with
	make uninstall

Use the same PREFIX for the uninstall as you used for install.

Build the documentation (pre-built documentation is distributed in
the distribution ZIP file) if you need to with:
	make doc

HTML documentation will be placed in the html subdirectory of the
distribution. An index to the HTML documentation is placed in
html/index.html. Plain text documentation will be placed in the doc
directory.

If you don't have the Perl library path in your Perl includes,
you'll need to add that directory to the PERLLIB environment variable.
You'll also need to put $(PREFIX)/bin in your PATH variable.

If, when you run getWizPnP, you get an error like:

	Can't locate XML/DOM.pm in @INC...
or
	Your system doesn't support multicast to discover WizPnP devices.
	Either install Perl package IO::Socket::Multicast, or
	use the --host option to specify your Beyonwiz's IP address
	or name.

you'll need to install some Perl modules. The CPAN library allows
you to download and install packages easily. CPAN uses the Perl
programming convention for naming modules. In the module name (such
as XML/DOM.pm) change all of the '/'s to '::' and drop
the '.pm'. So to download the package that's missing in  that error
message, just run:

	cpan XML::DOM
	
to install the XML::DOM module, and similarly for any other required
modules.

The Perl modules that you are most likely to need to install are:
	XML::DOM
	IO::Socket::Multicast
	IO::Interface::Simple

Running:
	make install
also checks whether the installation needs any modules that aren't available,
and won't complete the installation unless the modules are installed.

You can just run this check by running
	make check

Windows
=======

getWizPnP is written in the scripting language Perl (http://www.perl.org/).
Perl is not part of the Windows standard installation. getWizPnP
is known to work with the free version of ActivePerl
(http://www.activestate.com/).  Use version 5.10.0.1003 or more
recent.

There's no installation script for getWizPnP for Windows, but the
Makefile will work (see below, Using the Makefile on Windows), and
with some modifications (to the destination pathnames, for example), running
	make install
in a command window should work. Making the "precompiled" version of
getWizPnP should also work if you also install the PAR-Packer module
into ActivePerl using
	ppm install PAR-Packer

The simplest installation is to unpack getWizPnP into a suitable
location (say, in C:\Program Files) and add its directory
(C:\Program Files\getWizPnP if you've installed there) to your PATH
environment variable.

You'll also need to add the directory to your PERLLIB environment
variable, or create a new PERLLIB variable if there isn't one
already.

If, when you run getWizPnP, you get an error like:

	Can't locate XML/DOM.pm in @INC...
or
	Your system doesn't support multicast to discover WizPnP devices.
	Either install Perl package IO::Socket::Multicast, or
	use the --host option to specify your Beyonwiz's IP address
	or name.

you'll need to install some Perl modules. If you're using ActivePerl,
use the ActivePerl PPM library to get the module. PPM uses the Perl
form for naming modules. In the module name (such as
XML/DOM.pm) change all of the '/'s to '::' and drop
the '.pm'. So (at least in principe) to download the package that's
missing in that error message, just run:

	ppm install XML::DOM

The Perl modules that you are most likely to need to install are:
	XML::DOM
	IO::Socket::Multicast
	IO::Interface::Simple

Running:
	@checkModules
checks whether the installation needs any modules that aren't available.

Unfortunately, the module IO::Socket::Multicast is not available from
ppm the default ppm repository for some versions of ActivePerl.
If PPM doesn't find it, you can try using an alternative repository
if you want the functionality it provides (automatically discovering
Beyonwiz servers).

You can install IO::Socket::Multicast as follows (just type what follows
the 'prl>' prompt):

    prl>ppm repo add trouchelle
    Downloading ActiveState Package Repository packlist...not modified
    Downloading trouchelle packlist...done
    Updating trouchelle database...done
    Repo 2 added.

    prl>ppm repo list
    ----------------------------------------------
    | id | pkgs | name                           |
    ----------------------------------------------
    |  1 | 6524 | ActiveState Package Repository |
    |  2 | 9558 | trouchelle                     |
    ----------------------------------------------
     (2 enabled repositories)

    prl>ppm repo off 1

    prl>ppm search IO::Socket::Multicast
    Downloading ActiveState Package Repository packlist...not modified
    1: IO-Socket-Multicast
       Send and receive multicast messages
       Version: 1.05
       Author: Lincoln D. Stein <LDS@cpan.org>
       Provide: IO::Socket::Multicast version 1.05
       Repo: trouchelle
       CPAN: http://search.cpan.org/dist/IO-Socket-Multicast-1.05/

    prl>ppm install IO::Socket::Multicast
    Downloading IO-Socket-Multicast-1.05...done
    Unpacking IO-Socket-Multicast-1.05...done
    Generating HTML for IO-Socket-Multicast-1.05...done
    Updating files in site area...done
       7 files installed

    prl>ppm repo on 1
    Downloading ActiveState Package Repository packlist...done
    Updating ActiveState Package Repository database...done

    prl>ppm repo off 2

    prl>

The last two commands disable the trouchelle ppm repository and re-enable
the default ActivePerl ppm repository.

Unfortunately, IO::Interface::Simple module does not appear to be
available on any ppm repository. getWizPnP will still work, but the
unique names for Beyonwiz servers used in the --longNames will be
longer than they would be if the modle could be installed.

It is also possible to use the GUI interface to ppm to install any missing
ppm packages into ActivePerl. You can start the ppm GUI just by running it
without any command-line arguments:
	ppm

Using the Makefile on Windows
=============================

To run make on Windows you'll need to download GNU make package for Windows from
    http://gnuwin32.sourceforge.net/packages/make.htm
and the GNU CoreUtils package
    http://gnuwin32.sourceforge.net/packages/coreutils.htm

To make the precompiled ZIP packages in the getWizPnP release pages, you'll
also need the GNU Zip package
    http://gnuwin32.sourceforge.net/packages/zip.htm
and to examine it you may also want the GNU UnZip package
    http://gnuwin32.sourceforge.net/packages/unzip.htm

These packages install their programs in by default in
    C:\Program Files (x86)\GnuWin32\bin
and you'll need to add that to the end of your PATH environment variable
to use the commands and to run make on the Makefile.

This should allow you to run
    make doc
to generate getWizPnP text and HTML documentation,
    make compile
to make a "pre-compiled" version of getWizPnP and
    make zip-compile
to make a "pre-compiled" ZIP distribution package.
