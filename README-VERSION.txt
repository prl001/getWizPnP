Version 0.5.2

Main changes/differences/fixes in 0.5.2:

    * Added new option --check to do some basic consistency checks of
      recordings and media files on the Beyonwiz or in --inDir.
    * Fixed bug preventing recording deletion from working, and
      some unreported bugs in deletion of large (>1GB) media files
      on the Beyonwiz.

Bugs fixed in 0.5.2:

    * Some error messages printed while a recording is being
      transferred will cause a Perl internal error instead of
      printing the error message. Workaround: use verbosity level
      at least 1 when copying or moving recordings.
    * Loading the bookmarks for a recording goes into an infinite
      recursion, so verbosity level 3, which lists bookmarks will
      cause getWizPnP to go into an infinite recursion and crash.
    * If the main header file is modified by --reconstruct, the
      length of the bookmark table is set to the wrong value, usually
      much larger than it should be.
    * Reconstruction of the stat header file fails because a reference
      to the wrong object is used.

Known bugs in 0.5.2:

    * On Windows 7, sometimes getWizPnP fails to discover Beyonwiz
      servers on the network. The reason is not clear, but it can
      sometimes be worked around by specifying a larger timeout.
      Try --wizpnpTimeout=2.
   *  getWizPnp sometimes fail part-way through a recording copy
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
      episode name is sometimes actually the program synopsis.

File changes in 0.5.2
=====================

README-VERSION.txt
    Updated for 0.5.2 version information.

getWizPnP.pl
    Split ProgressBar class into ProgressBar that has no outputs
    and only calculates progress bar data, and TextProgressBar,
    which prints an ASCII text progress bar. The on-output ProgresBar
    is used for non-verbose output where undef was previously used.
    Fixed calls to getStat() that were passing a Trunc reference
    instead of a Header reference.

Beyonwiz/Recording/Accessor.pm
    Documentation of calls through $progressBar updated.

Beyonwiz/Recording/Header.pm
    Got rid of infinite recursive calls to bookmarks() method.
    Added symbolic MAX_BOOKMARKS.
    Check size of bookmarks table and reduce it to MAX_BOOKMARKS
    if it's too big.
    Set the number of bookmarks to the correct value in encodeBookmarks().

Beyonwiz/Recording/Recording.pm
    Calls to $progressBar simplified because $progressBar is no longer
    passed in as an undef.

Beyonwiz/Recording/FileAccessor.pm
    Calls through $progressBar simplified because $progressBar is no longer
    passed in as an undef.
    Documentation of calls through $progressBar updated.

Beyonwiz/Recording/HTTPAccessor.pm
    Calls through $progressBar simplified because $progressBar is no longer
    passed in as an undef.
    Documentation of calls through $progressBar updated.

html/Beyonwiz/Recording/Accessor.html
html/Beyonwiz/Recording/FileAccessor.html
html/Beyonwiz/Recording/HTTPAccessor.html
doc/FileAccessor.txt
doc/Accessor.txt
doc/HTTPAccessor.txt
    Documentation updates.
