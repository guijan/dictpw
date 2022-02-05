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

test('dictpw', dictpw)
test('-h', dictpw, args: '-h')
test('-n4', dictpw, args: '-n4')
test('-n8', dictpw, args: '-n8')

test('-n (empty flag)', dictpw, args: '-n', should_fail: true)
test('-n (too small)', dictpw, args: '-n1', should_fail: true)
test('-n (too large)', dictpw, args: '-n256', should_fail: true)
test('extraneous non-option argument 1', dictpw, args: '-', should_fail: true)
test('extraneous non-option argument 2', dictpw, args: ['--', '-h'],
     should_fail: true)
test('extraneous non-option argument 3', dictpw, args: ['-h', '--', 'extra'],
     should_fail: true)
test('extraneous non-option arguments', dictpw, args: ['-', '-n', 'f'],
     should_fail: true)
test('mix valid and invalid flag 1', dictpw, args: ['-h', '-n'],
     should_fail: true)
test('mix valid and invalid flag 2', dictpw, args: ['-n', '-h'],
     should_fail: true)
