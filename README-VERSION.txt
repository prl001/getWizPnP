Version 0.4.2

Main changes/differences/fixes in 0.4.2:

    * Added *LOCKED and *AC3 flags to the recording title line
      to indicate respectively that the recording has the File Lock set
      or has AC3 audio.
    * Added a line to the --Verbose=1 output to indicate the recording's
      Autodelete state. Not present for media files.
    * Remove leading ASCII control characters (0x00-0x1f) from title,
      episode name and synopsis fields, where they exist.
    * Moved printing the trunc file and the recording offset table
      from --verbose to --debug.
    * Added --debug option to pring the recording PIDs and some other
      header information, the trunc file and the recording offset table.
    * Print a warning and skip a recording if --move or --delete is
      used on a recording with File Lock set. Using --force overrides
      the warning and performs the operation anyway.

Bugs fixed in 0.4.2:

    * Leading ASCII control characters (0x00-0x1f) in title, episode name
      and synopsis fields are passed on to printing and used in
      constructing names for copied recordings.

Known bugs in 0.4.2:

    * The changes to the file indexing from 1.05.283 mean that
      if you delete a recording on the Beyonwiz (--delete/--move),
      it will remain in the internal index (i.e. visible in the
      file player, and visible in WizFX) until you start a recording
      index rebuild using FILEPLAYER, SOUNDTRACK on the remote, or
      a HDD check is done. This can only be fixed in the Beyonwiz
      firmware.
    * In free-to-air EPGs, the information used by getWizPnP for the
      episode name is sometimes actually the program synopsis.


File changes in 0.4.2
=====================

getWizPnP.pl
	Added *LOCKED and *AC3 flags to the recording title line
	to indicate respectively that the recording has the File Lock set
	or has AC3 audio.
	Added a line to the --Verbose=1 output to indicate the recording's
	Autodelete state. Not present for media files.
	Added %debugOpts and processDebug() to implement the --debug options.
	Added code to implement the --debug=pids debug option.
	Changed verbose levels 4 & 5 (trunc file & recording offset table)
	to be debug options.
	Print a warning and skip a recording if --move or --delete is
	used on a recording with File Lock set. Using --force overrides
	the warning and performs the operation anyway.

Beyonwiz/WizPnP.pm
	Removed support for Beyonwiz device lookup caching.

Beyonwiz/Recording/Header.pm
	Added new fields and accessor functions for the recently
	decoded magic number, version number, PIDs and auto-delete data.
	Removed the "unknown" fields.
	Remove ASCII control characters (0x00-0x1f) from the start of
	title, episode name and synopsis if tey are present.

html/Beyonwiz/WizPnP.html
html/Beyonwiz/Recording/Header.html
html/getWizPnP.html
doc/WizPnP.txt
doc/Header.txt
doc/getWizPnP.txt
	Generated documentation for modified scripts and modules.

