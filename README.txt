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

If, when you run any of the getWizPnP, you get an error like:

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


Windows
=======

getWizPnP is written in the scripting language Perl (http://www.perl.org/).
Perl is not part of the Windows standard installation. getWizPnP
is known to work with the free version of ActivePerl
(http://www.activestate.com/).  Use version 5.10.0.1003 or more
recent.

There's no installation script for getWizPnP for Windows.

The simplest installation is to unpack getWizPnP into a suitable
location (say, in C:\Program Files) and add its directory
(C:\Program Files\getWizPnP if you've installed there) to your PATH
environment variable.

You'll also need to add the directory to your PERLLIB environment
variable, or create a new PATHLIB variable if there isn't one
already.

If, when you run any of the getWizPnP, you get an error like:

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

	ppm XML::DOM

Unfortunately, the module IO::Socket::Multicast is *not* available from
ppm the default ppm repository, so if you want to have this functionality
in Windows, use an alternative repository.

**********************************************************************
*** Unfortunately, although this procedure appears to install
*** IO::Socket::Multicastcorrectly, the Perl code using it fails under
*** Windows, so for now, there doesn't appear any way of making WizPnP
*** device search work correctly on Windows.
**********************************************************************

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