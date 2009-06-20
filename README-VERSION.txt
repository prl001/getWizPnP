Version 0.4.1

Main changes/differences/fixes in 0.4.1:

    * Exclude some folders (mostly system and trash folders) when
      media files and recordings are searched for using --outdir.
    * Added --stopFolders option to allow users to specify the list of
      folders to be excluded when media files and recordings are
      searched for using --outdir.
    * Added extensions smi, srt and sub (subtitle files) to the
      default list of extensions recognised as media files
      when media files are searched for using --outdir.
    * Changed the order of printing information about WizPnP servers
      in --discover from name, IP address to IP address, name.

Bugs fixed in 0.4.1:

    * Allow an empty device name to be specified as -D "" or
      as --device=

Known bugs in 0.4.1:

    * The changes to the file indexing from 1.05.283 mean that
      if you delete a recording on the Beyonwiz (--delete/--move),
      it will remain in the internal index (i.e. visible in the
      file player, and visible in WizFX) until you start a recording
      index rebuild using FILEPLAYER, SOUNDTRACK on the remote, or
      a HDD check is done. This can only be fixed in the Beyonwiz
      firmware.


File changes in 0.4.1
=====================

getWizPnP.pl
	Added @stopFolders to implement list of excluded folders
	searched in --outdir.
	Added --stopFolders option to allow @stopFolders to be changed
	by user.
	Added smi, srt and sub to @mediaExtensions.
	Changed the order of printing information about WizPnP servers
	in --discover from name, IP address to IP address, name.
	Allow an empty device name to be specified as -D "" or
	as --device=

Beyonwiz/Recording/FileAccessor.pm
	Added support for $stopFolders to implement --stopFolders
	for getWizPnP

getwizpnp.conf
	Added smi, srt and sub to @mediaExtensions.
	Added @defaultStopFolders.

make_doc.sh:
	Change header generation in index.html to be for getWizPnP,
	not BWFWTools

html/index.html
html/getWizPnP.html
doc/getWizPnP.txt
	Generated documentation for modified scripts and modules.

