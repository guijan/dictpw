# Copyright (c) 2021-2022, 2024-2025
#     Guilherme Janczak <guilherme.janczak@yandex.com>
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

project('dictpw', 'c', version: '1.3.0', license: 'ISC',
        default_options: ['c_std=c99', 'warning_level=3'],
        meson_version: '>=1.4.0')

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
libbsd_dep = dependency('', required: false)
foreach func, header : funcs
  if not cc.has_function(func, prefix: header, args: args)
    libbsd_dep = dependency('libbsd-overlay',
                            default_options: 'default_library=static')
    break
  endif
endforeach

# Force subproject to be included by `meson dist --include-subprojects`
if get_option('release')
  subproject('libobsd')
endif

gen_dict = executable('gen_dict',
                      'src/gen_dict.c',
                      native: true)
gen_dict_h = custom_target('gen_dict',
                           output: 'gen_dict.h',
                           capture: true,
                           input: get_option('dict'),
                           feed: true,
                           depend_files: get_option('dict'),
                           command: gen_dict)

dictpw = executable('dictpw',
                    'src/dict.c',
                    'src/dictpw.c',
                    caps_c,
                    gen_dict_h,
                    install: true,
                    dependencies: libbsd_dep,
                    include_directories: incdir,
                    win_subsystem: 'console')
subdir('test')

install_man('src/dictpw.1')

if host_machine.system() == 'windows' or host_machine.system() == 'cygwin'
  # Build a .txt version of the manual too. For producing the installer.

  # Create groff IR version of the manual.
  man_groff = custom_target('man_groff',
                            command: [find_program('groff'), '-mdoc', '-Tascii',
                                      '-Z'],
                            input: [files('src/dictpw.1')],
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
  license = custom_target('license',
                         command: [unix2dos],
                         input: ['LICENSE.md'],
                         feed: true,
                         output: ['LICENSE.txt'],
                         capture: true,
                         build_by_default: true)
  readme = custom_target('readme',
                         command: [unix2dos],
                         input: ['README.md'],
                         feed: true,
                         output: ['README.txt'],
                         capture: true,
                         build_by_default: true)

  inst_cmd = [find_program('iscc'),
              '-DBUILDDIR=' + meson.current_build_dir(),
              '-Fsetup-dictpw',
              '-DMESON',
              '-DNAME=' + meson.project_name(),
              '-DVERSION=' + meson.project_version(),
              '-DURL=https://github.com/guijan/dictpw',
              # Inno Setup's ExtractFileName (basename function) expects the
              # Windows path separator ('\'), but Meson uses the Unix path
              # separator ('/'), so create a basename now.
              '-DEXEFILE=' + dictpw.full_path(),
              '-DLICENSE=' + license.full_path(),
              '-DMANFILE=' + man.full_path(),
              '-DREADME=' + readme.full_path(),]

  fs = import('fs')
  if libbsd_dep.found() and libbsd_dep.type_name() == 'internal'
    inst_cmd += '-DLIBOBSD_LICENSE=subprojects/libobsd/LICENSE_libobsd.txt'
  endif
  # Programs built in Cygwin and MSYS2's MSYS environment are linked against
  # a special DLL with their implementations of Unix inside, distribute it.
  dll_copy = []
  if host_machine.system() == 'cygwin'
    dlls = ['/usr/bin/msys-2.0.dll', '/bin/cygwin1.dll']
    found = false
    foreach dll : dlls
      if fs.is_file(dll)
        dll_copy += fs.copyfile(dll)
        inst_cmd += '-DMSYS_DLL=' + fs.name(dll)
        found = true
        break
      endif
    endforeach
    if not found
      error('cygwin/msys2 DLL not found')
    endif
  endif
  # Mapping between:
  # https://mesonbuild.com/Reference-tables.html
  # https://jrsoftware.org/ishelp/index.php?topic=archidentifiers
  meson_to_iscc_arch = {
    'arm': 'arm32compatible',
    'aarch64': 'arm64',
    'x86_64': 'x64compatible',
    'x86': 'x86compatible'
  }
  inst_cmd += '-DARCH=' + meson_to_iscc_arch[host_machine.cpu_family()]
  if cc.get_id() == 'msvc'
    # https://learn.microsoft.com/en-us/visualstudio/releases/2022/compatibility#build-apps-that-run-on-windows-clients
    winmin = '6.1sp1'
  else
    # https://www.msys2.org/docs/windows_support/
    # Minimum package requirement, not minimum toolchain requirement, I'm not
    # going to bother figuring out which is right, so use the highest one.
    winmin = '6.3'
  endif
  inst_cmd += '-DWIN_MIN=' + winmin
  run_target('installer',
             command: inst_cmd + files('src/dictpw.iss'),
             depends: [dictpw, man, license, readme, dll_copy])
endif
