/*
 * Copyright (c) 2011 Damien Miller <djm@mindrot.org>
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
#include <sandbox.h>

/* Heavily inspired by
 * https://github.com/openssh/openssh-portable/blob/3383b2cac0e9275bc93c4b4760e6e048f537e1d6/sandbox-darwin.c
 * The Damien Miller copyright in this file is due to copypasta from the
 * openssh-portable code above.
 */
void
caps(void)
{
	int ret;
	char *errorbuf;
	struct rlimit rl_tmp;

	/* sandbox_init() documented at
	 * https://www.unix.com/man-page/osx/3/sandbox_init/
	 */
	ret = sandbox_init(kSBXProfilePureComputation, SANDBOX_NAMED,
	    &errorbuf);
	if (ret == -1)
		errx(1, "sandbox_init: %s", errorbuf);

	/*
	 * The output may be redirected to a file, in which case the fsize limit
	 * applies.
	 */
	rl_tmp.rlim_max = rl_tmp.rlim_cur = 320;
	setrlimit(RLIMIT_FSIZE, &rl_tmp);

	/*
	 * The kSBXProfilePureComputation still allows sockets, so
	 * we must disable these using rlimit.
	 */
	rl_tmp.rlim_max = rl_tmp.rlim_cur = 0;
	setrlimit(RLIMIT_NOFILE, &rl_tmp);

	setrlimit(RLIMIT_NPROC, &rl_tmp);
}
