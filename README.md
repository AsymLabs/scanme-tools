scanme-tools  
=============

scanme-tools was created to enable an HP 1220 AIO scanner and printer to be
used under 32/64 bit Arch Linux/systemd/Gnome.  It could be useful for other
devices but non-hp scanners (ie epsom or brother for example) will require
different drivers.  Obviously each manufacturer will do things in their own
way.  

scanme-tools scripts 'scanme' and 'install.sh' are written in BASH.  They are
intended for use in Linux (Unix) systems.  

While we have used this script for some time, and have found it very reliable,
it hasd not been extensively tested.  Therefore you may find a problem from time
to time.  Please let us know about it.

Motivation
----------

Why produce another set of tools, you say?  Well we find that the current tools
are not complete, are not reliable or have other drawbacks.  So this tool can
scan document after document without problem.  At least that is our experience.  

Features and Usage
------------------

The application 'scanme' installs under the menu categories 'Multimedia' and
'Office' under Gnome, and is also installed on the path /usr/local/bin. It can
be invoked from the menu or a terminal window, but the behaviour is different.  

When accessed from the menu (best), a properties window is used to invoke the
application.  Post processing of files permits the scanned image or document to
have metadata attached to it.  This metadata has default settings that the user
can change.  The properties window also permits multiple, single or single scan
with view to be invoked.  The view will use a pdf viewer, as scans are made as
.tiff files and these are converted to .pdf and optimized.  

From the terminal, ScanMe can be invoked as follows:  

  scanme [-s|--single|-v|--view|-m|--multi|-h|--help]  

The above arguments are optional.  Without arguments the behaviour is the same
as calling ScanMe from a menu.  

When an option is given, the properties cannot be changed.  This is meant to
offer a 'fast-track' approach.  Options permit a single page to be scanned, a
single page with view (either acroread, evince, xpdf or gv are invoked), or
multiple pages with no view can be requested.  The help option produces the
simple message above.  

Scanned images are saved to a home subdirectory 'ScanMe-Work'. Two images are
produced: .tiff and .pdf.  Each .tiff image tends to be about 6 to 7 MB size,
typically, but the .pdf will be much smaller, around 200 to 400 KB.  

For multiple scans, each image is suffixed as -0000.tiff and -0000.pdf.  This
is a sequential number that will permit the images to stitched together if
required.  At the moment ScanMe does not do this stitching, but we are working
on another set of PDF tools that can do this work.  

Configuration
-------------

We have found that 'HPLIP+CUPS' is fine for printing, but that HPOJ is needed
for proper scanning with HP All-In-One devices such as laserjet and officejet
AIO.  Before installing, note that the package requires 'cups', 'sane', 'hplip',
'hpoj', 'tiff2pdf', 'ghostscript' and 'yad' (a better Zenity).  

Note that, at the time of writing (February 2014), the HP configuration tools
will require python 2.x.  So if strange errors occur, this is likely to be a
cause.  

This is systemd compatible, some systems may still use the older sysinit but
eventually all sysinit will be replaced by systemd.  As of this writing, Red
Hat, Gentoo and CentOS may still use sysinit, but just about all other major
distributions use systemd since about 2012.  Note that 'HPOJ' provides the
'ptal' server and installs sysinit scripts by default.  

Installation
------------
The script 'install.sh' can be invoked to install and uninstall the system.
Options are:  
  
  sudo ./install.sh {install|uninstall}  
  
The above installation should be done as a part of the procedure outlined below.
This is to ensure that the dependencies are correctly set up.  When an existing
file is found in '/etc', it will be backed up with the extension '.scanmesave'.
This is only done the first time.  When uninstalled, these files are restored
and all '.scanmesave' files are then removed.  

For files installed under '/usr' no backups are made, new files are either put
in the target directory or, if the file already exists, it will be overwritten.  

Thus './install.sh install' can be invoked more than once without uninstalling
should the software need to be updated.

Under this scenario we make no promise as to the integrity of the installation
procedure.  We advise caution.

If sysinit is used, rather than systemd, then comment the paths aarray entry for
'ptal.service' as follows:  
  
# paths['ptal.service']='/etc/systemd/system'  
  
Then do:  
  
- Install 'cups', 'sane', 'hplip', 'hpoj', 'tiff2pdf', 'ghostscript', 'yad'.  
- Set up the printer under 'cups' and ensure it works properly.  
- Do 'sudo hp-setup', 'sudo hp-plugins' and 'sudo ptal-init'.  
- Do 'hp-check -t' : copy the device string beginning with 'hpoj:mlc:'.  
- Edit 'scanme' and set 'device={device of step above}'.  
- Modify if using sysinit, otherwise just invoke './install.sh install'.  

Copyright and License
---------------------
This work is written by G R Summers and is Copyright (C) Applied Numerics Ltd
(AsymLabs), United Kingdom 2014, No warranty is implied or expressed.  Use at
your own risk.  See the file LICENSE in this directory for specific terms of
usage.  

If you are using it or if you are experiencing problems please let us know.  We
may be contacted at "Developer Team" <dv@angb.co>.

