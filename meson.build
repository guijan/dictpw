# Copyright (c) 2021-2022 Guilherme Janczak <guilherme.janczak@yandex.com>
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

project('dictpw', 'c', version: '1.1.1',
        default_options: ['c_std=c99', 'b_lto=true', 'warning_level=3'])

# Makes all functions, including BSD functions, visible on GNU.
args = ['-D_GNU_SOURCE']
cc = meson.get_compiler('c')
subdir('compat')
add_project_arguments(args, language: 'c')

funcs = {
  'arc4random_uniform': '#include <stdlib.h>',
  'errx': '#include <err.h>',
  'getprogname': '#include <stdlib.h>',
  'strtonum': '#include <stdlib.h>',
  'warnx': '#include <err.h>',
}
libbsd_dep = dependency('', required: false)
foreach func, header : funcs
  if not cc.has_function(func, prefix: header, args: args)
    libbsd_dep = dependency('libbsd-overlay')
    break
  endif
endforeach


gen_dict = executable('gen_dict',
                      'gen_dict.c',
                      dependencies: libbsd_dep)
gen_dict_h = custom_target('gen_dict',
                           output: 'gen_dict.h',
                           capture: true,
                           input: get_option('dict'),
                           feed: true,
                           depend_files: get_option('dict'),
                           command: gen_dict)

dictpw = executable('dictpw',
                    'dict.c',
                    'dictpw.c',
                    caps_c,
                    gen_dict_h,
                    install: true,
                    dependencies: libbsd_dep,
                    include_directories: incdir)
subdir('test')

if host_machine.system() != 'windows' and host_machine.system() != 'cygwin'
  install_man('dictpw.1')
else
  custom_target('manual',
		command : [find_program('groff'), '-mdoc', '-Tpdf', '--',
		           '@INPUT@'],
		input : [files('dictpw.1')],
		output : ['dictpw.pdf'],
		capture : true,
		install : true,
		install_dir : 'doc')
endif
