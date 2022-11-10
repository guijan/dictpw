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

project('dictpw', 'c', version: '1.2.0', license: 'ISC',
        default_options: ['c_std=c99', 'b_lto=true', 'warning_level=3'])

# Makes all functions, including BSD functions, visible on GNU.
args = ['-D_GNU_SOURCE']

cc = meson.get_compiler('c')

if cc.get_id() == 'msvc'
  # Spectre mitigations are off by default under MSVC for some ungodly reason.
  args += '/Qspectre'
  # https://docs.microsoft.com/en-us/cpp/c-runtime-library/multithreaded-libraries-performance?view=msvc-170#maximizing-performance
  args += '-D_CRT_DISABLE_PERFCRIT_LOCKS'
endif

add_project_arguments(args, language: 'c')

subdir('compat')

funcs = {
  'arc4random_uniform': '#include <stdlib.h>',
  'errx': '#include <err.h>',
  'getprogname': '#include <stdlib.h>',
  'strtonum': '#include <stdlib.h>',
  'warnx': '#include <err.h>',
}
libbsd_dep = []
foreach func, header : funcs
  if not cc.has_function(func, prefix: header, args: args)
    libbsd_dep = dependency('libbsd-overlay', static: get_option('static_deps'))
    break
  endif
endforeach

gen_dict = executable('gen_dict',
                      'gen_dict.c',
                      native: true)
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
                    include_directories: incdir,
                    win_subsystem: 'console')
subdir('test')

install_man('dictpw.1')

if host_machine.system() == 'windows' or host_machine.system() == 'cygwin'
  # Build a .txt version of the manual too. For producing the installer.

  # Create groff IR version of the manual.
  man_groff = custom_target('man_groff',
                            command: [find_program('groff'), '-mdoc', '-Tascii',
                                      '-Z'],
                            input: [files('dictpw.1')],
                            feed: true,
                            output: ['dictpw.groff'],
                            capture: true)
  # Convert groff to ASCII with Unix newlines.
  # '-bcou' means "don't use ANSI escapes".
  man_unix = custom_target('man_unix',
                           command: [find_program('grotty'), '-bcou'],
                           input: [man_groff],
                           feed: true,
                           output: ['dictpw.txt.unix'],
                           capture: true)

  unix2dos = find_program('unix2dos')
  # Convert Unix newlines to DOS newlines.
  man = custom_target('man',
                      command: [unix2dos],
                      input: [man_unix],
                      feed: true,
                      output: ['dictpw.txt'],
                      capture: true,
                      build_by_default: true)

  # Put copies of the license and the README with DOS newlines in the build
  # directory too.
  custom_target('license',
                command: [unix2dos],
                input: ['LICENSE.md'],
                feed: true,
                output: ['LICENSE.txt'],
                capture: true,
                build_by_default: true)
  custom_target('readme',
                command: [unix2dos],
                input: ['README.md'],
                feed: true,
                output: ['README.txt'],
                capture: true,
                build_by_default: true)
endif
