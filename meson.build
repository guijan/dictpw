# Copyright (c) 2021 Guilherme Janczak <guilherme.janczak@yandex.com>
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

project('dictpw', 'c',
  version : '1.0.0',
  default_options : ['c_std=c99', 'b_lto=true', 'warning_level=3'])

# Makes all functions, including BSD functions, visible on GNU.
cc_args = '-D_GNU_SOURCE'
add_project_arguments(cc_args, language : 'c')

cc = meson.get_compiler('c')
funcs = {
  'arc4random_uniform': '#include <stdlib.h>',
  'errx': '#include <err.h>',
  'getprogname': '#include <stdlib.h>',
  'strtonum': '#include <stdlib.h>',
  'warnx': '#include <err.h>',
}
libbsd_dep = dependency('', required : false)
foreach func, header : funcs
  if not cc.has_function(func, prefix : header, args : cc_args)
    libbsd_dep = dependency('libbsd-overlay')
    break
  endif
endforeach

executable('dictpw',
           'dict.c',
           'dictpw.c',
           install : true,
           dependencies : libbsd_dep)

install_man('dictpw.1')
