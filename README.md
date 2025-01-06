<!--
Copyright (c) 2021-2022, 2024-2025
    Guilherme Janczak <guilherme.janczak@yandex.com>

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
Dictpw randomly picks 4 words off a 7776-word dictionary and prints them with a
dot between each word. This is the
[Diceware](https://en.wikipedia.org/wiki/Diceware) method of password generation
from the command line.

Which of the following 2 passwords is easier to memorize?
```
computer.stuffy.dexterity.carve
J#2%Q*PDfNI
```

## Analysis
A password scheme's security can be measured by the number of distinct passwords
it can generate. To keep these incredibly large numbers intelligible, they're
given as exponents of 2, or bits. dictpw's default password length can generate
__7776^4__ distinct passwords, or __52 bits__ of security. Based on very
conservative estimates made using [my calculator](src/sec_pw_bits.bc), a 100-day
attempt to crack such a password with 500000 USD budget for hardware (not
counting electricity and labor) would have a 25% chance of succeeding in 2024.

The reasoning for these numbers is included in the calculator's source code.

## Example
```console
$ build/dictpw
canary.gnat.uncross.waking
$ build/dictpw -n3
chummy.iguana.outsider
```

## Compiling
Dictpw depends on [Meson](https://mesonbuild.com/) and a C compiler.
[Git](https://git-scm.com/) is one method to acquire the source code.
Some systems optionally depend on either
[libbsd](https://libbsd.freedesktop.org/) or
[libobsd](https://github.com/guijan/libobsd/), if neither is
present, libobsd is automatically downloaded and statically linked into dictpw.

### Linux, macOS, other Unix systems, and HaikuOS
Acquire the source code with git and enter its directory:
```console
$ git clone --depth 1 https://github.com/guijan/dictpw
$ cd dictpw
```

Compile the program:
```console
$ meson setup build && meson compile -C build
```
The binary will be in _build/dictpw_.

### Windows
Windows hosts optionally depend on Inno Setup in the `$env:PATH` to produce an
installer.

#### MSYS2
Install [MSYS2](https://www.msys2.org/) and follow the installation
instructions; make sure to read the
[MSYS2-Introduction](https://www.msys2.org/wiki/MSYS2-introduction/) page after
completing the installation instructions-failure to do so may break your MSYS2
installation.

The instructions below are the same for the UCRT64 (x64 binaries) and MINGW32
(x86 binaries) environments. Other environments aren't supported for end users.

Install the dependencies:
```console
foo@bar UCRT64 ~
$ winget install -e --id JRSoftware.InnoSetup
foo@bar UCRT64 ~
$ inno="$(cmd //c 'echo %ProgramFiles(x86)%' | cygpath -uf-)/Inno Setup 6/"
foo@bar UCRT64 ~
$ PATH="${PATH}:${inno}"
foo@bar UCRT64 ~
$ pacboys -S --noconfirm git: dos2unix: groff: gcc:p meson:p ninja:p
```

Acquire the source code with git and enter its directory:
```console
foo@bar UCRT64 ~
$ git clone --depth 1 https://github.com/guijan/dictpw
foo@bar UCRT64 ~
$ cd dictpw
```

Compile the program and installer:
```console
foo@bar UCRT64 ~/dictpw
$ meson setup build && meson compile installer -C build
```
The installer will be at _build/setup-dictpw.exe_, and the program itself will
be at _build/dictpw.exe_.

#### Visual Studio
Open up `powershell.exe` and install the dependencies via
[Chocolatey](https://chocolatey.org/):
```console
PS C:\Users\foo> choco install -y groff innosetup meson git dos2unix
PS C:\Users\foo> refreshenv
```

Acquire the source code with git and enter its directory:
```console
PS C:\Users\foo> git clone --depth 1 https://github.com/guijan/dictpw
PS C:\Users\foo> refreshenv
PS C:\Users\foo> cd dictpw
```

Compile the installer:
```console
PS C:\Users\foo\dictpw> meson setup build && meson compile installer -C build
```

## Windows documentation
The installer also installs the manual. Check _dictpw.txt_ inside the
installation directory.

## Custom dictionary
By default, dictpw uses the EFF's
[long word list](https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases).
You can specify a custom dictionary by setting the __dict__ option with Meson. A
dictionary is a file with one word per line.
