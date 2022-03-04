#!/bin/sh -evx

# Copyright (c) 2022 Guilherme Janczak <guilherme.janczak@yandex.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

OUTFILE='-DNULL'
while getopts o: o; do
case "$o" in
	o) OUTFILE="-DOUTFILE=${OPTARG}";;
	*) exit 1;;
esac
done

if ! [ -d 'build' ]; then
	meson setup -Dbuildtype=release build
fi
if ! [ -f 'build/dictpw.exe' ]; then
	meson compile -C build
fi

MSYS='-DNULL'
# Distribute msys-2.0.dll for the MSYS build.
if [ "$MSYSTEM" = "MSYS" ]; then
	msysdll='build\msys-2.0.dll'
	cp /usr/bin/msys-2.0.dll "$msysdll"
	MSYS="-DMSYS=$msysdll"
fi

# This profane incantation means "if I'm in MSYS or CLANG64, run MINGW64's
# makensis, else run my environment's makensis."
if [ "$MSYSTEM" = "MSYS" ] || [ "$MSYSTEM" = "CLANG64" ]; then
	subsh="/msys2_shell.cmd -defterm -here -no-start -mingw64 -c"
else
	subsh='bash -c'
fi

# The odd quoting is because the whole command line needs to be passed as a
# single argument to the subshell.
$subsh "makensis '$MSYS' '$OUTFILE' dictpw.nsi"
