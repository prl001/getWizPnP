Version 0.5.4a

Main changes/differences/fixes in 0.5.4a:

    * Add copyright notices to source files
    * Add MIT Open Source LICENCE file

Known bugs in 0.5.4a:

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

File changes in 0.5.4a
=====================

README-VERSION.txt
    Updated for 0.5.4a version information.

getWizPnP.pl
    Add copyright notices
    Updated VERSION.

All other .pl and .pm files:
    Add copyright notices

New Files
=========

LICENSE
    MIT Open Source licence.
