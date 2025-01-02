Changes in dictpw 1.3.0:

- Small performance tweak on UCRT
- Small tweaks to the manual
- Fix broken FreeBSD capsicum usage
- Don't force LTO
- Fix broken cross compiling
- Integrate the installer with Meson
- Change the installer's compression algorithm to LZMA to improve ratios
- Change to Inno Setup for the Windows installer for improved ARM support
- Set documentation read only on Windows to prevent accidental modification
- Add a portable install option to the Windows installer
- Add an option to add the program to $env:PATH on Windows
- Windows on 32-bit ARM support (for how long?)

