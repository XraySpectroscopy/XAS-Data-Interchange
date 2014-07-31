Tools for using XDI files
=========================

# Unix computers

 * `magic`: file type difinition for XDI for the [Unix file type recognition system](http://en.wikipedia.org/wiki/File_%28command%29)
 * `install_magic`: Bash shell script for installing the contents of the `magic` file


Install XDI file magic as root:

        ~> sudo ./install_magic

This assumes that the file `/etc/magic` is used for local magic data.
If the local file magic file is in some other location on your
computer, then

        ~> sudo ./install_magic /path/to/magic

where `/path/to/magic` is that location on your computer.

Once installed, XDI files can be identified with the [file command](http://en.wikipedia.org/wiki/File_%28command%29):

	    ~> file -m magic data/co_metal_rt.xdi 
		data/co_metal_rt.xdi: XAS Data Interchange file -- XDI specification 1.0

# Windows computers

Modify the Windows registry to assign an icon to `.xdi` files.

**PLEASE NOTE:**

	      This works, but is currently an imperfect solution.  The
		  location of the icon is hard wired in the registry file.
		  Thus, the registry file must currently be edited by hand to
		  point to the correct location of the icon file.

	      A script that installed the icon file to a suitable
          location, modifies the registry file, then runs the regsitry
          edit would be a welcome contribution!


 * `xdi.ico`: Windows icon for XDI files
 * `xdi.reg`: Windows registry entry for XDI files

Double click on the `xdi.reg` file to modify a computer's registry.
Once this is done, XDI files will be displayed using the XDI icon.

See http://stackoverflow.com/questions/8407066/how-do-i-associate-a-filetype-with-an-icon
and the MSDN link on that page.
