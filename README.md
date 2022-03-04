<!--
Copyright (c) 2021-2022 Guilherme Janczak <guilherme.janczak@yandex.com>

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

# Dictpw - generate password from dictionary
Dictpw randomly picks 5 words off a 7776-word dictionary and prints them with a
dot between each word. This is the
[Diceware](https://en.wikipedia.org/wiki/Diceware) method of password generation
from the command line.

Which of the following 2 passwords is easier to memorize?
```
computer.stuffy.dexterity.carve.wife
J#2%Q*PDfNI
```

## Analysis
There are __7776^5__ or __28430288029929701376__ possible passwords using
dictpw's default word count.
There are __(23+23+10+10)^10__ or __1568336880910795776__ possible passwords in
a random 10 character password composed of uppercase characters, lowercase
characters, digits, and the symbols on top of each digit on the keyboard, or 18
times less possible passwords. Dictpw by default sits between a 10 and 11
character long password of such a scheme.

## Build instructions
Dictpw depends on [Meson](https://mesonbuild.com/), a C compiler, and a
POSIX-like or Windows operating system.

Install Meson, and follow the build instructions:
```sh
meson setup build
meson compile -C build
```
By default, the dictpw build will use the system's BSD functions if they are
present, attempt to link against an installed libbsd if they're not present, or
fall back to building and statically linking
[libobsd](https://github.com/guijan/libobsd) if all else fails. Whether linking
against libbsd or falling back to libobsd are allowed can be configured from
Meson in the usual way.

The binary will be in _build/dictpw_.

## Custom dictionary
By default, dictpw uses the EFF's
[long word list](https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases).
You can specify a custom dictionary by setting the __dict__ option with Meson. A
dictionary is a file with one word per line.

## Example
```console
foo@bar ~
$ build/dictpw
canary.gnat.uncross.waking.expose
foo@bar ~
$ build/dictpw -n4
chummy.iguana.outsider.yearling
```

## Windows support
### Build from MSYS2
Install [MSYS2](https://www.msys2.org/) and follow the installation
instructions; make sure to read the
[MSYS2-Introduction](https://www.msys2.org/wiki/MSYS2-introduction/) page after
completing the installation instructions-failure to do so may break your MSYS2
installation.

The rest of this section describes a MINGW64 build.

Install the dependencies:
```console
foo@bar MSYS ~
$ pacman --noconfirm -S git groff mingw-w64-x86_64-gcc mingw-w64-x86_64-meson \
    mingw-w64-x86_64-ninja mingw-w64-x86_64-nsis mingw-w64-x86_64-dos2unix
```
Now start the MINGW64 environment, and enter the directory to which you
downloaded the dictpw sources.
Produce the installer for a release build:
```console
foo@bar MINGW64 ~/dictpw
$ meson setup build
foo@bar MINGW64 ~/dictpw
$ sh dictpw_installer.sh
```

#### MSYS environment build instructions
Building releases with the MSYS compatibility layer is also supported.
The process is the same, except the dependencies are different:
```console
foo@bar MSYS
$ pacman --noconfirm -S dos2unix git groff gcc meson ninja mingw-w64-x86_64-nsis
```
Obviously, you don't need to enter a different environment to build the MSYS
version.

#### CLANG64 environment build instructions
The CLANG64 build process, too, only differs from the MINGW64 build process in
the dependency list:
```console
foo@bar MSYS
$ pacman --noconfirm -S git groff mingw-w64-clang-x86_64-clang \
    mingw-w64-clang-x86_64-dos2unix mingw-w64-clang-x86_64-meson \
    mingw-w64-clang-x86_64-ninja mingw-w64-x86_64-nsis
```
Make sure to enter the CLANG64 environment after installing the dependencies and
before following the build instructions.

Notice that no matter the MSYS2 environment you're building dictpw in, the
dependencies are always the environment's version of the same packages-except
you must install the MINGW64 NSIS for environments missing a NSIS package.

#### Others
Dictpw builds on all of
[MSYS2's environments](https://www.msys2.org/docs/environments/).
MINGW64 and MINGW32 are the most stable MSYS2 environments, therefore they are
the only supported environments. The build is kept in working order in all the
others purely for the sake of portability.

### Build from Visual Studio
#### Native build
Open up `cmd` and install the dependencies via
[Chocolatey](https://chocolatey.org/):
```
C:\Users\foo>choco install -y groff strawberryperl nsis meson
C:\Users\foo>refreshenv
```
`cd` into the directory to which you downloaded the sources and build the
project:
```
C:\Users\foo\dictpw>meson setup --backend=vs build
C:\Users\foo\dictpw>meson compile -C build
```
Make the installer:
```
C:\Users\foo\dictpw>makensis dictpw.nsi
```
The Windows on AArch8 installer can't be compiled natively because NSIS doesn't
support AArch8 installers.

Additionally, please note that NSIS doesn't distribute 64-bit builds of
`makensis`, so you have to compile your own. There's no support for installing
the 64-bit version with a 32-bit installer.

#### Cross compile to Aarch8 from x64
This is the only way to make an AArch8 installer. The installer is x64 and runs
on AArch8 through Windows' x64 emulation, but the binaries it installs are
native.

Change the build step to this:
```
C:\Users\foo\dictpw>meson setup --backend=vs ^
    --cross-file=.github/workflows/meson-vs-aarch64.txt build
C:\Users\foo\dictpw>meson compile -C build
```

## Windows example
Unfortunately, Microsoft hasn't provided a proper way to install command line
utilities to Windows. The installer registers the .exe in the Windows Registry
which allows running the program from `cmd` using the `start` command:
```
C:\Users\foo>start /b /wait dictpw
unusual.skewer.swirl.whinny.rogue
```
Keep in mind the /b and /wait flags are necessary: they tell cmd.exe not to
start another cmd.exe, and to wait for the program's exit.

## Windows documentation
The installer also installs the manual. Check _dictpw.txt_ inside the
installation directory.
