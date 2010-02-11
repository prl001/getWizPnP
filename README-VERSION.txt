Version 0.4.3a

Main changes/differences/fixes in 0.4.3a:

    * Worked around a bug in the Beyonwiz firmware that caused too much of
      a recording to be transferred in --ts mode if the recording had
      been edited/created with Keep A->B or Copy A->B to New File.
    * Changed the outputs of recording sizes, transfer rates and recording
      bitrates from MiB and MiB to MB and Mb.
    * Recordings that have been "topped" now transfer correctly in
      --ts mode.
    * If you specify --resume on a "topped" recording that hasn't been
      started, the recording transfers correctly.

Bugs fixed in 0.4.3a:

    * Worked around a bug in the Beyonwiz firmware that caused too much of
      a recording to be transferred in --ts mode if the recording had
      been edited/created with Keep A->B or Copy A->B to New File.
      This is strictly a workaraound for a Beyonwiz bug, rather than a
      getWizPnP bug fix.
    * Recordings that have been "topped" now transfer correctly in
      --ts mode.
    * If you specify --resume on a "topped" recording that hasn't been
      started, the recording transfers correctly.

Known bugs in 0.4.3a:

    * The changes to the file indexing from 1.05.283 mean that
      if you delete a recording on the Beyonwiz (--delete/--move),
      it will remain in the internal index (i.e. visible in the
      file player, and visible in WizFX) until you start a recording
      index rebuild using FILEPLAYER, SOUNDTRACK on the remote, or
      a HDD check is done. This can only be fixed in the Beyonwiz
      firmware.
    * In free-to-air EPGs, the information used by getWizPnP for the
      episode name is sometimes actually the program synopsis.

Thanks to glow on the Beyonwiz forum for finding the bugs in the length
of the --ts recording transfers for Keep A->B or Copy A->B to New File
recordings, and the problem with transferring "topped" recordings.

File changes in 0.4.3a
=====================

getWizPnP.pl
	Changed the outputs of recording sizes, transfer rates and recording
	bitrates from MiB and MiB to MB and Mb.
	Fixed packages list in PREREQUISITES documantation.

Beyonwiz/Recording/Trunc.pm
	Documentation correction.

Beyonwiz/Recording/Recording.pm
	Worked around a bug in the Beyonwiz firmware that caused too much of
	a recording to be transferred in --ts mode if the recording had
	been edited/created with Keep A->B or Copy A->B to New File.
	Recordings that have been "topped" now transfer correctly in
	--ts mode.
	If you specify --resume on a "topped" recording that hasn't been
	started, the recording transfers correctly.

Beyonwiz/Recording/HTTPAccessor.pm
	Removed some unnecessary imports.

doc/HTTPAccessor.txt
doc/Trunc.txt
doc/getWizPnP.txt
html/Beyonwiz/Recording/HTTPAccessor.html
html/Beyonwiz/Recording/Trunc.html
html/getWizPnP.html
	Generated documentation for modified scripts and modules.

html/Beyonwiz/Recording/Accessor.html
html/Beyonwiz/Recording/FileAccessor.html
html/Beyonwiz/Recording/Header.html
html/Beyonwiz/Recording/Index.html
html/Beyonwiz/Recording/IndexEntry.html
html/Beyonwiz/Recording/Recording.html
html/Beyonwiz/Recording/TruncEntry.html
html/Beyonwiz/Utils.html
html/Beyonwiz/WizPnP.html
html/Beyonwiz/WizPnPDevice.html
	Documentation changed because of new version of pod2html.
