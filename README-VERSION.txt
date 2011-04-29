Version 0.5.0

Main changes/differences/fixes in 0.5.0:

    * Added --reconstruct option to reconstruct missing trunc and stat files.
    * If the trunc and stat files can't be found, look for them under some of
      the other names they sometimes get renamed to on the Beyonwiz. Copy
      them with their correct names.
    * No longer open/close a TS file for each copied recording dada file.
      May help avoid errors caused by anti-virus and file monitoring
      programs opening the files when getWizPnP still wants to
      access them.
    * Use 'recordings' as path prefix for recordings instead of 'recording',
      to match Beyonwiz usage.
    * Make match on MOVIE: for --dictionarySort=movie case-insensitive.
    * Fixed bug in --dictionarySort=case: case insensitivity was
      being controlled by --dictionarySort=movie.
    * Added explicit --copy option.
    * Added --debug=stat option to print the recording size in the stat file.
    * Added --version for printing version.
    * Allow --inDir & --outDir as well as --indir and --outdir for more
      camelCase consistency in long option names. All lower case
      is now deprecated for this option.
    * Verbosity level 4 (not 3) now includes the file's index name,
      as stated in the documentation.
    * Improved formatting of error messages when copying is in progress.
      Added more informative error messages when there's a HTTP error.
    * Progress bar display now more robust if progress goes over 100%.
    * Some clarification and correction in the documentation.
    * Added Makefile entries to create 'compiled' versions of getWizPnP
      using pp, and include documentation with them.

Bugs fixed in 0.5.0:

    * No longer open/close a TS file for each copied recording dada file.
      May help avoid errors caused by anti-virus and file monitoring
      programs opening the files when getWizPnP still wants to
      access them.
    * Make match on MOVIE: for --dictionarySort=movie case-insensitive.
    * Fixed bug in --dictionarySort=case: case insensitivity was
      being controlled by --dictionarySort=movie.
    * Improved formatting of error messages when copying is in progress.
      Error message during a copy should now start cleanly on a new line
      when the copy is verbose, rather than being appended to the
      progress bar line.
    * Progress bar display now more robust if progress goes over 100%.
    * Verbosity level 4 (not 3) now includes the file's index name,
      as stated in the documentation.

Known bugs in 0.5.0:

    * The changes to the file indexing from 1.05.283 mean that
      if you delete a recording on the Beyonwiz (--delete/--move),
      it will remain in the internal index (i.e. visible in the
      file player, and visible in WizFX) until you start a recording
      index rebuild using FILEPLAYER, SOUNDTRACK on the remote, or
      a HDD check is done. This can only be fixed in the Beyonwiz
      firmware.
    * In free-to-air EPGs, the information used by getWizPnP for the
      episode name is sometimes actually the program synopsis.

Thanks to qmandol on the Beyonwiz forum for identifying the likely cause
of the TS copy mode errors.

File changes in 0.4.3a
=====================

README-VERSION.txt
    Updated for 0.5.0 version information.

getWizPnP.pl
	Added explicit --copy option.
	Added --reconstruct option to reconstruct missing trunc and stat files.
	Added --debug=stat option to print the recording size in the stat file.
	Added --version for printing version.
	Allow --inDir & --outDir as well as --indir and --outdir for more
	camelCase consistency in long option names. All lower case
	now deprecated.
	Verbosity level 4 (not 3) now includes the file's index name,
	as stated in the documentation.
	Added new options to documentation, and tidied up --help printout.
	Added newLine method to ProgressBar to simplify error message
	formatting when a copy is in progress.
	Added indicator to ProgressBar for when the progress goes over 100%.
	Use 'recordings' as the name of the Beyonwiz recordings folder, no
	longer fake up Recording as the recordings folder.
	Fixed bug in --dictionarySort=case: case insensitivity was
	being controlled by --dictionarySort=movie.
	Make match on MOVIE: for --dictionarySort=movie case-insensitive,
	and use ':' instead of _ to match '_' fix in IndexEntry::title().
	Moved some of the detail printing in doRecordingOperation() into
	subroutines to make control flow in doRecordingOperation()
	a bit clearer. Tidied up doRecordingOperation() control flow.
	Add warning when recording skipped because of missing stat header file.
	Fixed up some errors and missing bits in the documentation.

Beyonwiz/Recording/Stat.pm
	New class to represent the stat header file, to allow it to be printed
	(--debug=stat), searched for under non-standard names and
	reconstructed.

Beyonwiz/Recording/Header.pm
	Added reconstructed() method to tyest whether reconstruction of other
	headers modified the main header.
	Added updateOffsets() method to estimate new values for the
	time/offset table when the trunc teader is reconstructed.
	Added encode methods to reconstruct the header as a file.
	Tidied up and updated documentation.

Beyonwiz/Recording/IndexEntry.pm
	Change '_' characters before space to ':'. Most '_' chars
	in that context are recoded ':' chars.

Beyonwiz/Recording/Trunc.pm
	Search for names that the trunc file can be renamed to.
	Added method to return the file name that was actually found
	in the search.
	Added reconstruction capability to search for recording data files and
	rebuild an approximate trunc file, if the trunc file can't be found.
	Added encode function so that reconstructed trunc data can be
	written to file.
	Use symbolic constants for formats and offsets so that they can
	be shared between decode and encode methods.
	Tidied up and updated documentation.

Beyonwiz/Recording/Recording.pm
	Added putFile() method to write reconstructed headers.
	Added stat object to getRecording() method to allow
	for its reconstruction.
	Integrate header reconstruction functionality to write reconstructed
	headers from their objects instead of copying them.
	Use new open/close file handle methods in Accessor() so
	that TS files can be written in one open/write/close sequence,
	instead of a series of open/write/close operations, one for
	each recording data file. May help avoid errors caused by
	anti-virus and file monitoring programs opening the files
	when getWizPnP still wants to access them.
	Add stat object to deleteRecording() method so it can be deleted
	even if it has the wrong name. Also use actual header name found
	when deleting trunc header file.
	Tidied up and updated documentation.

Beyonwiz/Recording/Accessor.pm
	New methods to open and close recording output file to help
	with writing TS files in one go in
	Beyonwiz::Recording::Recording::getRecording().
	Change abstract implementation of getRecordingFile()
	and getRecordingFile() methods to add quiet flag.
	Use ProgressBar::newIlne() to help format error messages.
	Tidied up and updated documentation.

Beyonwiz/Recording/FileAccessor.pm
	Use new open/close file handle methods in Accessor() so
	that TS files can be written in one open/write/close sequence,
	instead of a series of open/write/close operations, one for
	each recording data file. May help avoid errors caused by
	anti-virus and file monitoring programs opening the files
	when getWizPnP still wants to access them.
	Add a time/date stamp on constructed recording names in loadIndex()
	if the name doesn't have one, and use the recording start time
	instead of the Unix timestamp on the main header file, if the
	header file can be loaded.
	Cleaned up error message interaction with quiet flag and
	use ProgressBar::newLine() to help format error messages.
	Tidied up and updated documentation.

Beyonwiz/Recording/HTTPAccessor.pm
	Use 'recordings' as path prefix for recordings instead of 'recording',
	to match Beyonwiz usage.
	Use new open/close file handle methods in Accessor() so
	that TS files can be written in one open/write/close sequence,
	instead of a series of open/write/close operations, one for
	each recording data file. May help avoid errors caused by
	anti-virus and file monitoring programs opening the files
	when getWizPnP still wants to access them.
	Use more informative status_line() HTTP messages instead of
	status_message().
	Cleaned up error message interaction with quiet flag and
	use ProgressBar::newIlne() to help format error messages.
	Tidied up and updated documentation.

make_doc.sh
	MacOS 10.6.7 made pod2hltm and pod2text non-executable for
	no apparent reason. Explicitly run perl on them.

README.txt
	Bit of tidying up and correcting cut/paste errors carried over from
	the BWFWTools README.txt.

Makefile
	Added Stat.pm.
	Added entries to create 'compiled' versions of getWizPnP
	using pp, and include documentation with them.

html/Beyonwiz/Recording/Stat.html
doc/Stat.txt
	Documentation for Beyonwiz::Recording::Stat

html/Beyonwiz/Recording/Recording.html
html/Beyonwiz/Recording/Accessor.html
html/Beyonwiz/Recording/FileAccessor.html
html/Beyonwiz/Recording/HTTPAccessor.html
html/Beyonwiz/Recording/Header.html
html/Beyonwiz/Recording/Trunc.html
html/getWizPnP.html
html/index.html
doc/HTTPAccessor.txt
doc/Accessor.txt
doc/FileAccessor.txt
doc/getWizPnP.txt
doc/Header.txt
doc/Trunc.txt
doc/Recording.txt
	Documentation updates.
