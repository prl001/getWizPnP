Version 0.4

Main changes/differences/fixes in 0.4:

    * Handles media files on the Beyonwiz, both in single file format and
      Beyonwiz folder format.
    * Recordings and media files can be accessesd in both the recordings
      and content folders.
    * --folder defaults to --folder=recordings. Older versions allowed
      subfolders to be specified by theit name relative to recordings
      (e.g. recordings/Movies was specified by --folder=Movies).
      Now the full name must be given, i.e. --folder=recordings/Movies.
      But you can now also specify --folder=content/Movies (for
      example). To see everything on the Beyonwiz, use --folder=/
      --all. When trashcan moves to the top level, that should be
      accessible, too. I'm considering allowing the recordings and
      content folders to be shortened to 'r' and 'c' (and 't').
    * Can copy media files from the Beyonwiz, optionally joining them
      into a single file on the PC if they are in folder format.
    * Can copy media files from the Beyonwiz, optionally joining
      them into a single file on the PC if they are in folder format.
    * Option --join/--nojoin controls whether media file folders are
      joined to a single file on the output. The default action
      (unlike --ts) is --join.
    * Matching device names using --device is now a case-insensitive
      substring match. Can be made a prefix match if people prefer.
    * Device search defaults to an exhaustive search (--maxdevs=0)
      instead of exiting the search when the first device responds
      (--maxdevs=1).
    * Option --longNames allows devices with the same name to be
      disambiguated. Devices will be named wizpnpname-hostnum-port.
      Hostnum is the host address part of the server's IP address
      instead of the host address. Can be easily changed to use the
      whole IP address.
    * Fixed some bugs in the stitching-together of folder format
      recordings into single files.
    * Resuming a download now uses a byte-accurate start point for
      resumption. The old code always started at the beginning of
      the incomplete fragment file. That was OK (but untidy) for
      32MB fragment files, but not for the 1GB fragment files in
      the media file format.
    * Fixed bug that caused the recording data files to not be
      deleted by --delete and --move.
    * Added new scripts checkModules.pl and checkModules.bat
      to check that all necessary system modules are installed.
      checkModules.pl incorporated into "make install".
    * --date now includes the start time in the recording name.


Known new bugs:

    * The changes to the file indexing in 1.05.283 mean that if you delete
      a recording on the Beyonwiz (--delete/--move), it will remain
      in the internal index (i.e. visible in the file player, and
      visible in WizFX) until you start a recording index rebuild
      using FILEPLAYER, SOUNDTRACK on the remote, or a HDD check
      is done. This can only be fixed in the Beyonwiz firmware.


File changes
============

Beyonwiz/WizPnP.pm
	Allows for naming of WizPnP servers when names aren't unique.
	Make use of Beyonwiz::Utils::tryUse for optional modules.
	More flexible lookup allowing for substring matching on
	long and short names.
	Sorting on name/IP/port.
	Added optional timeout and nPolls to test code in main()

Beyonwiz/WizPnPDevice.pm
	Added netmask to allow for calculation of host address.
	Added generation of long names for devices.
	Added access to IP addr, host addr and port.

Beyonwiz/Utils.pm
	Added isAbstract function as a utility to help define
	abstract methods in classes.
	Added tryUse function for loading optional modules.

Beyonwiz/Recording/Index.pm
	Uses an accessor class to handle HTTP and file access.

Beyonwiz/Recording/Recording.pm
	Uses an accessor class to handle HTTP and file access.
	Added flexible generation of date format and recording format
	for recording name generation.
	Added support for single-file or Beyonwiz folder format for
	media files in the Contents folder.
	Byte-accurate resume of downloads.
	More general handling of whether downloaded recordings/media
	files are joined into a single file.

Beyonwiz/Recording/Header.pm
	Uses an accessor class to handle HTTP and file access.
	Added index entry for the recording.
	Added method to extract the header name from the object.
	Added support for single-file or Beyonwiz folder format for
	media files in the Contents folder.
	path() and name() methods to extract the corresponding values
	from the index entry.
	Method to convert Unix timestamps to Beyonwiz MJD timestamps.

Beyonwiz/Recording/IndexEntry.pm
	Uses an accessor class to handle HTTP and file access.
	Added support for single-file or Beyonwiz folder format for
	media files in the Contents folder.
	Simplified the path() function.

Beyonwiz/Recording/Trunc.pm
	Uses an accessor class to handle HTTP and file access.
	Added support for single-file or Beyonwiz folder format for
	media files in the Contents folder.
	Support byte-accurate resume of downloads.
	More robust calculation of fileTrunc.

getWizPnP.pl
	--longNames for disambiguation of WizPnP server names.
	--nameFormat, --dateFormat & --dateLast for formatting
	recording names.
	--join for joining media files on transfer.
	Ability to specify recordings and files in the Contents folder.
	More documentation of WizPnP naming.
	Specify Beyonwiz device by partial match.
	Better error reporting on device search.
	
getwizpnp.conf
	Added options for --dateLast, --longNames, --join,
	--nameFormat, --dateFormat and named user date and name formats.

README.txt
	Added information about module checking.

Makefile
	Updated modules list for build.

html/Beyonwiz/Utils.html
html/Beyonwiz/WizPnP.html
html/Beyonwiz/WizPnPDevice.html
html/Beyonwiz/Recording/Recording.html
html/Beyonwiz/Recording/TruncEntry.html
html/Beyonwiz/Recording/Index.html
html/Beyonwiz/Recording/Header.html
html/Beyonwiz/Recording/IndexEntry.html
html/Beyonwiz/Recording/Trunc.html
html/getWizPnP.html
html/index.html
doc/WizPnPDevice.txt
doc/getWizPnP.txt
doc/WizPnP.txt
doc/Header.txt
doc/IndexEntry.txt
doc/Trunc.txt
doc/Recording.txt
	Generated documentation for modified scripts and modules.

New files
=========

checkModules.pl
	Check that the modules used or required in a list of perl
	script files are available on the system.

README-VERSION.txt
	This file: Release notes.

checkModules.bat
	Windows script to check the components of getWizPnP
	using checkModules.pl

Beyonwiz/Recording/Accessor.pm
Beyonwiz/Recording/FileAccessor.pm
Beyonwiz/Recording/HTTPAccessor.pm
html/Beyonwiz/Recording/Accessor.html
html/Beyonwiz/Recording/FileAccessor.html
html/Beyonwiz/Recording/HTTPAccessor.html
doc/Accessor.txt
doc/FileAccessor.txt
doc/HTTPAccessor.txt
	Abstract Accessor class and File and HTTP implementations
	to perform the basic access functions for the input side of
	getWizPnP, and the generated documentation.


Deleted files
=============

html/Beyonwiz/Recording/HTTPRecording.html
html/Beyonwiz/Recording/FileRecording.html
html/Beyonwiz/Recording/HTTPHeader.html
html/Beyonwiz/Recording/FileHeader.html
html/Beyonwiz/Recording/FileIndexEntry.html
html/Beyonwiz/Recording/HTTPIndexEntry.html
html/Beyonwiz/Recording/HTTPTrunc.html
html/Beyonwiz/Recording/FileTrunc.html
html/Beyonwiz/Recording/FileIndex.html
html/Beyonwiz/Recording/HTTPIndex.html
doc/FileIndex.txt
doc/HTTPIndex.txt
doc/FileRecording.txt
doc/HTTPRecording.txt
doc/FileHeader.txt
doc/HTTPHeader.txt
doc/HTTPIndexEntry.txt
doc/FileIndexEntry.txt
doc/HTTPTrunc.txt
doc/FileTrunc.txt
Beyonwiz/Recording/HTTPIndex.pm
Beyonwiz/Recording/FileIndex.pm
Beyonwiz/Recording/HTTPRecording.pm
Beyonwiz/Recording/FileRecording.pm
Beyonwiz/Recording/HTTPHeader.pm
Beyonwiz/Recording/FileHeader.pm
Beyonwiz/Recording/FileIndexEntry.pm
Beyonwiz/Recording/HTTPIndexEntry.pm
Beyonwiz/Recording/FileTrunc.pm
Beyonwiz/Recording/HTTPTrunc.pm
	Modules and documentation deleted when the Accesor
	classes introduced.
