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

## DESCRIPTION
dictpw is a very simple password generation program. Every time you run it, it
randomly picks a default of 5 words off a 7776-word dictionary and prints them
with a separator (currently a period) between each word. The user can pick more
or less words, though the program prohibits nonsensically small or large
passwords.
This is the [Diceware](https://en.wikipedia.org/wiki/Diceware) method of
password generation on the command line.

There are 7776^5 or 28430288029929701376 possible passwords using dictpw's
default scheme.
If you were to generate a completely random 10 character password composed of
uppercase characters, lowercase characters, digits, and the symbols on top of
each digit on the keyboard, that would mean (23+23+10+10)^10 or
1568336880910795776 possible passwords, or 18 times less possible passwords.
dictpw by default sits between a 10 and 11 character long password of such a
scheme.

Which of the following 2 passwords is easier to memorize?
```
computer.stuffy.dexterity.carve.wife
J#2%Q*PDfNI
```

## BUILD INSTRUCTIONS
dictpw depends on [Meson](https://mesonbuild.com/), and it may depend on
[libbsd](https://libbsd.freedesktop.org/wiki/) depending on the system.

Install Meson, and follow the build instructions:
```
$ meson setup build
$ meson compile -C build
```

Meson will tell you if libbsd is required or missing. Run
`meson compile -C build` again after installing libbsd if it was missing.

The binary will be in build/dictpw

## CUSTOM DICTIONARY
By default, dictpw uses the EFF Large Wordlist dictionary.
The awk script at dict.awk can generate a custom dictionary. Read its top level
comment for instructions.

## EXAMPLE
```
$ build/dictpw
canary.gnat.uncross.waking.expose
$ build/dictpw -n4
chummy.iguana.outsider.yearling
```
