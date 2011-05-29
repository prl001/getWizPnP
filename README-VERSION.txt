Version 0.5.1

Main changes/differences/fixes in 0.5.1:

    * Added new option --check to do some basic consistency checks of
      recordings and media files on the Beyonwiz or in --inDir.
    * Fixed bug preventing recording deletion from working, and
      some unreported bugs in deletion of large (>1GB) media files
      on the Beyonwiz.

Bugs fixed in 0.5.1:

    * Fixed bug preventing recording deletion from working, and
      some unreported bugs in deletion of large (>1GB) media files
      on the Beyonwiz.

Known bugs in 0.5.1:

    * The changes to the file indexing from 01.05.283 mean that
      if you delete a recording on the Beyonwiz (--delete/--move),
      it will remain in the internal index (i.e. visible in the
      file player, and visible in WizFX) until you start a recording
      index rebuild using FILEPLAYER, SOUNDTRACK on the remote, or
      a HDD check is done. This can only be fixed in the Beyonwiz
      firmware.
    * In free-to-air EPGs, the information used by getWizPnP for the
      episode name is sometimes actually the program synopsis.

File changes in 0.5.1
=====================

README-VERSION.txt
    Updated for 0.5.1 version information.

getWizPnP.pl
	Added new option --check to do some basic consistency checks of
	recordings and media files on the Beyonwiz or in --inDir.
	Fixed "skipped" in warning when stat file is missing - a missing
	stat file doesn't cause the operation to be skipped.
	Simplified some tests in recording operations.

Beyonwiz/Utils.pm
	Added missing space in error message.

Beyonwiz/Recording/Index.pm
	Minor fix to documentation.

Beyonwiz/Recording/Header.pm
	Added method to return length and modified time for the
	underlying file.
	Set default file names if load() fails.

Beyonwiz/Recording/Stat.pm
	Fixes to documentation.
	Added method to return length and modified time for the
	underlying file.
	Set default file names if load() fails.

Beyonwiz/Recording/Trunc.pm
	Fixes to documentation.
	Added method to return length and modified time for the
	underlying file.
	Set default file names if load() fails.
	FULLFILE definition moved to Beyonwiz::Recording::TruncEntry.
	Add accessor and path when Beyonwiz::Recording::TruncEntry
	constructed.
	Use new Beyonwiz::Recording::TruncEntry::fileName() method
	for the printable form of the entry's file name.
	Use use TRUNC_SIZE_MULT and WMMETA symbolic sizes and offsets
	instead of numbers.
	Fix amount of padding in the reconstructed header in encode().

Beyonwiz/Recording/Recording.pm
	Use new Beyonwiz::Recording::TruncEntry::fileName() method
	for the printable form of the entry's file name.
	Fixed various bugs in deleteRecording(), especially the
	parameters to $self->accessor->deleteRecordingFile(...)
	method calls.

Beyonwiz/Recording/TruncEntry.pm
	Fixes to documentation.
	Added method to return length and modified time for the
	underlying file.
	New fileName() method for the printable form of the entry's
	file name.
	FULLFILE definition moved here from Beyonwiz::Recording::Trunc.

Beyonwiz/Recording/Check.pm
	New class to implement the recording consistency checks
	for getWizPnP's --check option.

README.txt
	Using the trouchelle repository seems no nlonger necessary
	to get IO::Socket::Multicast. The notes now reflect this.

Makefile
	Added Beyonwiz/Recording/Check.pm to the module list.
	Add targets for making source and compiled ZIPs.

make_doc.sh
	Restored the pod2html and pod2text commands back to normal so
	that they run with perlbrewed perl 5.12.3.

html/Beyonwiz/Utils.html
html/Beyonwiz/WizPnP.html
html/Beyonwiz/WizPnPDevice.html
html/Beyonwiz/Recording/Recording.html
html/Beyonwiz/Recording/TruncEntry.html
html/Beyonwiz/Recording/Check.html
html/Beyonwiz/Recording/Accessor.html
html/Beyonwiz/Recording/FileAccessor.html
html/Beyonwiz/Recording/HTTPAccessor.html
html/Beyonwiz/Recording/Index.html
html/Beyonwiz/Recording/Header.html
html/Beyonwiz/Recording/IndexEntry.html
html/Beyonwiz/Recording/Trunc.html
html/Beyonwiz/Recording/Stat.html
html/getWizPnP.html
html/index.html
doc/Index.txt
doc/Stat.txt
doc/Recording.txt
doc/TruncEntry.txt
doc/Check.txt
doc/getWizPnP.txt
doc/Header.txt
doc/Trunc.txt
	Documentation updates.
