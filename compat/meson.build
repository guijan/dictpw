# Copyright (c) 2022,2025 Guilherme Janczak <guilherme.janczak@yandex.com>
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
#

incdir = include_directories('.')

# The choices are ordered from best to worst. Thus, pledge should be used if
# it's implemented, followed by capsicum, and so on.
if cc.has_function('pledge', args: args, prefix: '#include <unistd.h>')
  caps_c = files('caps_pledge.c')
elif cc.has_function('cap_enter', args: args,
                     prefix: '#include <sys/capsicum.h>') and \
     cc.has_function('procctl', args: args, prefix: '#include <sys/procctl.h>')
  caps_c = files('caps_capsicum.c')
elif cc.has_function('sandbox_init', args: args, prefix: '#include <sandbox.h>')
  caps_c = files('caps_sandbox_init.c')
# emscripten's setrlimit is stubbed and prints unnecessary warnings, ignore it.
elif cc.has_function('setrlimit', args: args,
                     prefix: '#include <sys/resource.h>') and \
     host_machine.system() != 'emscripten'
  if host_machine.system() == 'haiku'
    args += '-DARC4RANDOM_NEEDS_FD'
  endif
  caps_c = files('caps_setrlimit.c')
else
  caps_c = files('caps_null.c')
endif
