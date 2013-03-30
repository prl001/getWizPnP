Version 0.5.4

Main changes/differences/fixes in 0.5.4:

    * Allow the use of GETWIZPNPCONF environment to specify the
      getWizPnP configuration file rather than use the programmed
      default. If GETWIZPNPCONF is set to an empty string, then
      no configuration file is loaded at startup. Intended to allow
      the use os alternative configuration files, especially for
      programs like YARDWiz and WizZillathat provide GUI interfaces
      to getWizPnP.
    * Fixed bug which caused a Perl internal error message instead
      of the intended getWizPnP error message if an error occurred
      in a recording copy or move.
    * Fixed several bugs that contributed to getWizPnP --resume
      not resuming recording correctly.
    * The test to avoid seeking on stdout if it was a pipe or socket
      was incorrect. It failed if the output file was a newly-created
      file (-s used instead of -S). Fixed.
    * Added options --before and --since to limit
      downloads by recording times.
    * Fixed lack of error reporting when syswrite() fails during a HTTP
      GET request.
    * Change all the HTTP_BAD_REQUEST error returns generated in
      getWizPnP to HTTP_FORBIDDEN to avoid triggering --retry
      re-fetches when the error didn't come from the Beyonwiz.
    * --retry to retry downloads automatically after some causes of
      failure (especially 400 Bad Request).
    * Allow user control of the format of the date string used for
      matching recordings.
     **This changes the default format of the match date.**
    * In the progress bar on --resume, show progress for the whole
      recording, not just the progress over the part being resumed.
    * Documentation of new features in  getWizPnP documentation.
    * Some tidying-up of getWizPnP documentation.
    * Added undocumented --delay option.
    * Added make_doc.pl for POD documentation extraction; should have been
      included in 0.5.3.

Bugs fixed in 0.5.4:

    * A Perl internal error message was produced instead
      of the intended getWizPnP error message if an error occurred
      in a recording copy or move.
    * getWizPnP --resume not resuming recording correctly.
    * The test to avoid seeking on stdout if it was a pipe or socket
      was incorrect. It failed if the output file was a newly-created
      file (-s used instead of -S).
    * No error bessage was produced on a failure of syswrite() when
      downloading a file in a recording. This also caused the download
      to continue when it should have been aborted.
    * Unix file errors were returned as HTTP_BAD_REQUEST. This would
      trigger retries specified in --retry. The retries should only
      be triggered when a HTTP_BAD_REQUEST cane from the Beyonwiz
      server.
    * Added make_doc.pl for POD documentation extraction; should have been
      included in 0.5.3.

Known bugs in 0.5.4:

    * On Windows 7, sometimes getWizPnP fails to discover Beyonwiz
      servers on the network. The reason is not clear, but it can
      sometimes be worked around by specifying a larger timeout.
      Try --wizpnpTimeout=2.
    * getWizPnp sometimes fails part-way through a recording copy
      with a HTTP 400 - Bad Request error. WizFX also seems to have
      similar problems on Windows 7. The cause of the problem is
      not clear, but it may be something common to both getWizPnP
      and WizFX.
    * The changes to the file indexing from 01.05.283 mean that
      if you delete a recording on the Beyonwiz (--delete/--move),
      it will remain in the internal index (i.e. visible in the
      file player, and visible in WizFX) until you start a recording
      index rebuild using FILEPLAYER, SOUNDTRACK on the remote, or
      a HDD check is done. This can only be fixed in the Beyonwiz
      firmware.
    * In free-to-air EPGs, the information used by getWizPnP for the
      episode name is sometimes actually the program synopsis. This is
      in the broadcast data and so is not strictly a getWizPnP bug.
    * Only Australian time zones are available for use by
      --before and --since.

File changes in 0.5.4
=====================

README-VERSION.txt
    Updated for 0.5.4 version information.

getWizPnP.pl
    Allow the use of GETWIZPNPCONF environment to specify the
    getWizPnP configuration file rather than use the programmed
    default. If GETWIZPNPCONF is set to an empty string, then
    no configuration file is loaded at startup. Intended to allow
    the use os alternative configuration files, especially for
    programs like YARDWiz and WizZilla that provide GUI interfaces
    to getWizPnP.
    Fixed bug which caused a Perl internal error message instead
    of the intended getWizPnP error message if an error occurred
    in a recording copy or move.
    Added options --before and --since and --between to limit
    downloads by recording times.
    --retry to retry downloads automatically after some causes of
    failure (especially 400 Bad Request).
    Simplified the code that handles new-line printing when the
    progress bar is being used.
    Allow user control of the format of the date string used for
    matching recordings.
    *This changes the default format of the match date.*
    Updated documentation for new functions.
    Some tidying-up of documentation.

checkModules.pl
    Add DateTime::TimeZone::Local::Win32 to the list of OS-optional
    modules needed for Windows (and Cygwin) to check that everything
    is there that's needed for --before and --since.

Beyonwiz/Recording/Trunc.pm
    Fixed wrong number of arguments being passed to
    Beyonwiz::Recording::Trunc->new in makeFileTrunc & fileTruncFromDir.
    This contributed to fixing --resume.
    Some cosmetic changes.

Beyonwiz/Recording/Recording.pm
    Corrected construction of $fileTrunc, which is used for the
    actual downloading of Beyonwiz .tvwiz recordings.
    In the progress bar on --resume, show progress for the whole
    recording, not just the progress over the part being resumed.
    Change all the HTTP_BAD_REQUEST error returns to HTTP_FORBIDDEN
    to avoid triggering --retry re-fetches when the error didn't
    come from the Beyonwiz.
    Some cosmetic changes.

Beyonwiz/Recording/HTTPAccessor.pm
    The test to avoid seeking on stdout if it was a pipe or socket
    was incorrect. It failed if the output file was a newly-created
    file (file test -s used instead of -S). Fixed.
    Added support for undocumented --delay option.
    Fixed lack of error reporting when syswrite() fails during a HTTP
    GET request.
    Change all the HTTP_BAD_REQUEST error returns to HTTP_FORBIDDEN
    to avoid triggering --retry re-fetches when the error didn't
    come from the Beyonwiz.

Beyonwiz/Recording/Accessor.pm
    Change all the HTTP_BAD_REQUEST error returns to HTTP_FORBIDDEN
    to avoid triggering --retry re-fetches when the error didn't
    come from the Beyonwiz.

Beyonwiz/Recording/FileAccessor.pm
    Change all the HTTP_BAD_REQUEST error returns to HTTP_FORBIDDEN
    to avoid triggering --retry re-fetches when the error didn't
    come from the Beyonwiz.

getwizpnp.conf
    Added user control of defaults for --before & --since.
    Added user control of default for --retry.
    Updated example for @folderList to include Recordings/ in the
    folder paths.

README.txt
    Added DateTime::Format and Params::Validate modules to the lists
    of modues that are likely to be needed to be installed by the
    user for getWizPnP to work.

Makefile
    Make use of Beyonwiz/PPModules.pm in make compile and make check
    to ensure that dynamically loaded modules used by DateTime are
    checked for presence and included in getWizPnP "compiled" packages.

html/getWizPnP.html
doc/getWizPnP.txt
    Updated documentation for new functions.

New Files
=========

make_doc.pl
    Perl script to create documentation using the pod2* tools.
    Intended to be more portable than a shell script. Should have been
    included in 0.5.3 and apparently wasn't.

Beyonwiz/PPModules.pm
    "uses" modules that are loaded dynamically in DateTime so that they
    are included in pp packages made in Makefile. If these packages aren't
    listed here, then they won't be included in a package made with pp, and
    the pre-packages getWizPnP won't work.
