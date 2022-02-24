/*
 * Copyright (c) 2022 Guilherme Janczak <guilherme.janczak@yandex.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <sys/resource.h>

#include <err.h>
#include <errno.h>

#include <caps.h>

void
caps(void)
{
	struct rlimit rl_tmp;

	rl_tmp.rlim_max = rl_tmp.rlim_cur = 320;
	setrlimit(RLIMIT_FSIZE, &rl_tmp);

/* This limits the memory usage. Last time I checked, this program used 600KiB
 * statically linked on OpenBSD, and 1.6MiB dynamically linked on OpenBSD.
 * Using /usr/share/dict/words from OpenBSD increases memory usage to 8.8MiB.
 * Also, the cygwin DLL is around 4MiB in size.
 * A 16MiB cap on memory usage is a good worst case.
 */
#if defined(RLIMIT_AS) /* POSIX but not available at least on OpenBSD. */
	rl_tmp.rlim_max = rl_tmp.rlim_cur = 1024*1024*16;
	setrlimit(RLIMIT_AS, &rl_tmp);
#elif defined(RLIMIT_RSS) /* Not POSIX but almost the same thing. */
	rl_tmp.rlim_max = rl_tmp.rlim_cur = 1024*1024*16;
	setrlimit(RLIMIT_RSS, &rl_tmp);
#endif

	rl_tmp.rlim_max = rl_tmp.rlim_cur = 0;
	/*
	 * My OpenBSD compatiblity library needs /dev/urandom to provide
	 * arc4random on HaikuOS, so I can't remove the capability to open
	 * files there.
	 */
#if !defined(ARC4RANDOM_NEEDS_FD)
	setrlimit(RLIMIT_NOFILE, &rl_tmp);
#endif

	/* The following are Non-POSIX but useful. */
#if defined(RLIMIT_NPROC)
	setrlimit(RLIMIT_NPROC, &rl_tmp);
#endif
#if defined(RLIMIT_KQUEUES)
	setrlimit(RLIMIT_KQUEUES, &rl_tmp);
#endif
#if defined(RLIMIT_NPTS)
	setrlimit(RLIMIT_NPTS, &rl_tmp);
#endif
}
