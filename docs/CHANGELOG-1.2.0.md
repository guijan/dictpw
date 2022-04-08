Changes in dictpw 1.2.0:

- Make changelogs readable when concatenated
- Overhaul capability limitations to be more portable and strict
- Port to Visual Studio
- Port to Windows AArch8
- Add cross compilation support
- Switch the Windows manual to plaintext
- Make deleting the uninstaller the last step in the uninstallation process
- Uninstall a previously installed version of the program before installing a
  new one to delete old files
- Remove the old NSIS UI to cut down on useless choice
- Fix a random text file being installed to a bogus directory on Cygwin
- Guarantee text files installed by the installer have DOS newlines on Windows

