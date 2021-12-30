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
