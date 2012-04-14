Version 0.5.3

Main changes/differences/fixes in 0.5.3:

    * Allow output of downloaded recordings to stdout.
    * Adds a consistency check to --check between the trunc entry
      sizes and the recording offsets in the trunc file. The recording
      offsets should be a running total of the sizes.
    * Fixed a bug in --check where header file size errors were
      being reported as wrong-name errors.
    * When checking trunc file entries in --trunc, don't reload
      the recording file's header info if the entry is for the same
      recording file as the previous entry.
    * Offsets printed in --debug=trunc and --debug=offsets now
      print correctly on Windows (this bug only appears to have
      affected ActivePerl on Windows, including the distributed
      "compiled" version for Windows).
    * Fixes a bug that was causing an incorrect estimated start
      time for the last trunc entry printed by --debug=trunc if the
      last entry played for more than 10 sec.
    * getWizPnP HTTP request rate limited so that it no longer
      uses up large numbers of available ephemeral ports.  Port
      usage is limited to 20% of available ephemeral ports on Windows
      XP and older, and 10% of available ephemeral ports on other
      systems.  If, despite the rate limiting above, getWizPnP does
      exhaust the host's ephemeral ports, it now retries the request
      if a request fails because of a connection timeout.
    * Reduced the number of HTTP requests needed to fetch the
      header.tvwiz data to improve performance of common operations
      when the port usage is restricted.
    * Changed the make_doc.sh (Unix shell script) to make_doc.pl
      (Perl script) to make documentation  generation more portable
      to Windows, but the script has problems when run from within
      a Makefile on the Windows port of Gnu make. Some cosmetic
      improvements to the HTML output. These scripts are not included
      in"compiled" versions.
    * Modified Makefile for use on Windows with Gnu utilities.
      Only affects developers.  Not visible to users of "compiled"
      versions.
    * Modified Makefile to include this file and getwizpnp.conf
      in the "compiled" ZIP files.
    * Added the ability to checkModules.pl to only issue warnings
      about some optional modules on particular systems. Mainly so
      that builds on non-Windows based systems don't complain about
      the Win32 module not being available. Only affects developers.
      Not visible to users of "compiled" versions.


Bugs fixed in 0.5.3:

    * getWizPnP --check was intermittently incorrectly reporting
      missing files on Windows XP. This was caused by the ephemeral
      ports used on the local side of an IP connection being exhausted
      because of the large numbers of short HTTP HEAD requests
      issued to check the presence and size of recording files.
      getWizPnP HTTP request rate limited so that it no longer uses
      up large numbers of available ephemeral ports.  Port usage
      is limited to 20% of available ephemeral ports on Windows XP
      and older, and 10% of available ephemeral ports on other
      systems.  If, despite the rate limiting above, getWizPnP does
      exhaust the host's ephemeral ports, it now retries the request
      if a request fails because of a connection timeout.
      Allow the number of ephemeral ports and the fraction to be used
      to be specified by the user in the getwizpnp.conf file.
    * Offsets printed in --debug=trunc and --debug=offsets now
      print correctly on Windows (this bug only appears to have
      affected ActivePerl on Windows, including the distributed
      "compiled" version for Windows).
    * Fixes a bug that was causing an incorrect estimated start
      time for the last trunc entry printed by --debug=trunc if
      the last entry played for more than 10 sec.
    * Fixes a bug in the construction of the recording index data
      on local (host computer, rather than the Beyonwiz) that was
      causing warnings to be printed in some versions of Perl if
      recording folders didn't have a filename extension.

Known bugs in 0.5.3:

    * On Windows 7, sometimes getWizPnP fails to discover Beyonwiz
      servers on the network. The reason is not clear, but it can
      sometimes be worked around by specifying a larger timeout.
      Try --wizpnpTimeout=2.
    * getWizPnp sometimes fail part-way through a recording copy
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

File changes in 0.5.3
=====================

checkModules.pl
    Allow the ability to have optional modules checked only for
    particular operating systems.

README.txt
    Updated to describe how to use the Makefile on Windows. Mention
    using the ppm GUI instead of the ppm command like interface.

README-VERSION.txt
    Updated for 0.5.3 version information.

getWizPnP.pl
    Allow output of downloaded recordings to stdout.
    Allow normal stdout output to be sent to stderr when --stdout option
    is used.
    Adds a consistency check to --check between the trunc entry
    sizes and the recording offsets in the trunc file. The recording
    offsets should be a running total of the sizes.
    Explicit imports from HTTP::Status.
    Commented out 'use bignum' - causes problems in Cygwin's
    handling of the sort comparison functions.
    Offsets printed in --debug=trunc and --debug=offsets now
    print correctly on Windows (this bug only appears to have
    affected ActivePerl on Windows, including the distributed
    "compiled" version for Windows).
    Add documentation for --stdout option.
    Documented ephemeral port use limits in --check.
    Typos fixed in documentation.

getwizpnp.conf
    Add entry example for useStdout.
    Add entry examples for the number of ephemeral ports
    and the fraction to be used by getWizPnP.
    Some cosmetic changes.

Makefile
    Modified Makefile to make it usable on Windows using Windows
    ports and the Unix shell tools. Include README-VERSION.txt and
    getwizpnp.conf in the "compiled" ZIP files.  Only affects
    developers. Not visible to users of "compiled" versions.
    In particular changed variable 'OS' to 'OSNAME' because the
    OS environment variable is used by the Windows pod2html script,
    and setting OS in the Makefile caused an unexpected OS name to
    be passed into the script.

make_doc.pl
    Changed the make_doc.sh (Unix shell script) to make_doc.pl
    (Perl script) to make documentation  generation more portable
    to Windows. Some cosmetic improvements to the HTML output.
    These scripts are not included in"compiled" versions.

make_doc.pl
    Removed: replaced by make_doc.pl

Beyonwiz/WizPnP.pm
    Explicit imports from HTTP::Status.

Beyonwiz/Recording/Accessor.pm
    Allow output of downloaded recordings to stdout.

Beyonwiz/Recording/Header.pm
    Fixes a bug in the construction of the recording index data
    on local (host computer, rather than the Beyonwiz) that was
    causing warnings to be printed in some versions of Perl where
    recording folders didn't have a filename extension.
    Avoid unnecessary HTTP HEADs by using extension names rather than
    testing for file existance when checking whether a recording/media
    path is a recording or a media file.
    Avoid unnecessary HTTP GETs by loading all the relevant part of
    the header.tvwiz file at once rather than in pieces.

Beyonwiz/Recording/Recording.pm
    Allow output of downloaded recordings to stdout.
    Explicit imports from HTTP::Status. Use HTTP_* for HTTP errors
    instead of RC_*.
    Added documentation for $useStdout, and some typo fixes.
    Fixed documentation to refer to HTTP_* for HTTP errors instead
    of RC_*.

Beyonwiz/Recording/Stat.pm
    Set size() to undef if the load of the stat file fails,
    instead of to 0. Improves error handling in Check.

Beyonwiz/Recording/Trunc.pm
    Set size() to undef if the load of the stat file fails,
    instead of to 0. Improves error handling in Check.
    Use %u (unsigned) printf format instead of %d (signed)
    for printing file numbers.

Beyonwiz/Recording/TruncEntry.pm
    Use %u (unsigned) printf format instead of %d (signed)
    for printing file numbers.
    Add "use bignum" pragma.

Beyonwiz/Recording/Check.pm
    Adds a consistency check to --check between the trunc entry
    sizes and the recording offsets in the trunc file. The recording
    offsets should be a running total of the sizes.
    When checking trunc file entries, don't reload the recording
    file's header info if the entry is for the same recording file
    as the previous entry.
    Use Stat and Trunc size() methods for the file sizes instead of
    doing an extra HPPT HEAD to tehs the existance of the files
    and their sizes

Beyonwiz/Recording/Accessor.pm
    Avoid closing the output file handle if it's stdout.
    Explicit imports from HTTP::Status. Use HTTP_* for HTTP errors
    instead of RC_*.
    Fixed documentation to refer to HTTP_* for HTTP errors instead
    of RC_*.

Beyonwiz/Recording/FileAccessor.pm
    Fixes a bug in the construction of the recording index data
    on local (host computer, rather than the Beyonwiz) that was
    causing warnings to be printed in some versions of Perl where
    recording folders didn't have a filename extension.
    Don't give a warning if sysseek() fails on a pipe. Supports
    --stdout being redirected into a pipe.
    Explicit imports from HTTP::Status. Use HTTP_* for HTTP errors
    instead of RC_*.
    Fixed documentation to refer to HTTP_* for HTTP errors instead
    of RC_*.

Beyonwiz/Recording/HTTPAccessor.pm
    Allow output of downloaded recordings to stdout.
    getWizPnP --check was intermittently incorrectly reporting
    missing files on Windows XP. This was caused by the ephemeral
    ports used on the local side of an IP connection being exhausted
    because of the large numbers of short HTTP HEAD requests
    issued to check the presence and size of recording files.
    getWizPnP HTTP request rate limited so that it no longer uses
    up large numbers of available ephemeral ports.  Port usage
    is limited to 20% of available ephemeral ports on Windows XP
    and older, and 10% of available ephemeral ports on other
    systems.  If, despite the rate limiting above, getWizPnP does
    exhaust the host's ephemeral ports, it now retries the request
    if a request fails because of a connection timeout.
    Allow the number of ephemeral ports and the fraction to be used
    to be specified by the user in the getwizpnp.conf file.
    Explicit imports from HTTP::Status. Use HTTP_* for HTTP errors
    instead of RC_*.
    Fixed documentation to refer to HTTP_* for HTTP errors instead
    of RC_*.

html/getWizPnP.html
doc/getWizPnP.txt
    Add documentation for --stdout option.
    Documented ephemeral port use limits in --check.
    Typos fixed in documentation.

html/Beyonwiz/Recording/Recording.html
doc/Beyonwiz/Recording/Recording.txt
    Added documentation for $useStdout, and some typo fixes.
    Fixed documentation to refer to HTTP_* for HTTP errors instead
    of RC_*.

html/Beyonwiz/Recording/Accessor.html
doc/Beyonwiz/Recording/Accessor.txt
    Fixed documentation to refer to HTTP_* for HTTP errors instead
    of RC_*.

html/Beyonwiz/Recording/HTTPAccessor.html
doc/Beyonwiz/Recording/HTTPAccessor.txt
    Fixed documentation to refer to HTTP_* for HTTP errors instead
    of RC_*.

html/Beyonwiz/Recording/FileAccessor.html
doc/Beyonwiz/Recording/FileAccessor.txt
    Fixed documentation to refer to HTTP_* for HTTP errors instead
    of RC_*.

html/Beyonwiz/Recording/TruncEntry.html
doc/Beyonwiz/Recording/TruncEntry.tct
    Change documentation to say that %u (unsigned) printf format
    is used instead of %d (signed) for printing file numbers.
