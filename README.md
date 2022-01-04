<!--
Copyright (c) 2021 Guilherme Janczak <guilherme.janczak@yandex.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
-->

## Dictpw - dictionary-based password generator
Dictpw randomly picks 5 words off a 7776-word dictionary and prints them with a
dot between each word. This is the
[Diceware](https://en.wikipedia.org/wiki/Diceware) method of password generation
from the command line.

Which of the following 2 passwords is easier to memorize?
```
computer.stuffy.dexterity.carve.wife
J#2%Q*PDfNI
```

## Build instructions
Dictpw depends on [Meson](https://mesonbuild.com/), and it may depend on
[libbsd](https://libbsd.freedesktop.org/wiki/) depending on the system.

Install Meson, and follow the build instructions:
```
$ meson setup build
$ meson compile -C build
```
Meson will tell you if libbsd is required or missing. Run
`meson compile -C build` again after installing libbsd if it was missing.

The binary will be in _build/dictpw_.

## Analysis
There are __7776^5__ or __28430288029929701376__ possible passwords using
dictpw's default word count.
There are __(23+23+10+10)^10__ or __1568336880910795776__ possible passwords in
a random 10 character password composed of uppercase characters, lowercase
characters, digits, and the symbols on top of each digit on the keyboard, or 18
times less possible passwords. Dictpw by default sits between a 10 and 11
character long password of such a scheme.

## Custom dictionary
By default, dictpw uses the EFF's
[long word list](https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases).
The awk script at dict.awk can generate a custom dictionary. Read its top level
comment for instructions.

## Example
```
$ build/dictpw
canary.gnat.uncross.waking.expose
$ build/dictpw -n4
chummy.iguana.outsider.yearling
```

## Windows support
### Windows build instructions
Dictpw intends to build on all of
[MSYS2's environments](https://www.msys2.org/docs/environments/). Currently,
there are some limitations:
- The CLANG32 environment hasn't been confirmed to work yet.
- The .nsi script can't produce an installer for the Cygwin build
- The .nsi script can't install Microsoft's Universal C Runtime for the user
- NSIS is only available for MINGW64, UCRT64, and MINGW32

This leaves us with MINGW64 and MINGW32 for producing releases.

Install [MSYS2](https://www.msys2.org/), follow the installation instructions.
Make sure to read the
[MSYS2-Introduction](https://www.msys2.org/wiki/MSYS2-introduction/) page after
completing the installation instructions, failure to do so may break your MSYS2 installation.

The build instructions below assume a MINGW64 build.

Install the dependencies:
```console
foo@bar MSYS ~
$ pacman --noconfirm -S git groff mingw-w64-gcc mingw-w64-meson mingw-w64-ninja
```
Now start the MINGW64 environment, and enter the directory to which you
downloaded the dictpw sources.
To produce the installer, run:
```console
foo@bar MINGW64 ~/dictpw
$ sh ./dictpw_installer.sh
```
The script automatically sets up the Meson build directory on release mode and
with stripping turned on, compiles the sources, and runs the .nsi script.
The installer will be at _build/setup-dictpw-local.exe_.

### Windows example
Unfortunately, Microsoft hasn't provided a proper way to install command line
utilities to Windows. The installer registers the .exe in the Windows Registry,
which allows running the program from `cmd.exe` using the `start` command:
```
C:\Users\foo>start /b /wait dictpw
unusual.skewer.swirl.whinny.rogue
```
Keep in mind the /b and /wait flags are necessary. They tell cmd.exe not to
start another cmd.exe, and to wait for the program to exit.

### Windows documentation
The installer also installs the manual. Check _dictpw.pdf_ inside the
installation directory.
