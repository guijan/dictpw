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

#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* We can't depend on err() from libbsd because Meson doesn't support depending
 * on the same library in the build and the host systems.
 */
static int myerr(int, int, const char *, ...);

/* gen_dict: Generate the members of a C array declaration from a list of words.
 *
 * The list comes from stdin, the members go to stdout.
 */
int
main(void)
{
	/* Deliberately small to forbid absurdly large words. */
	char word[32];
	size_t wordlen;

	for (;;) {
		if (fgets(word, sizeof(word), stdin) == NULL) {
			if (ferror(stdin))
				myerr(1, 1, "fgets");
			break;
		}

		word[strcspn(word, "\r\n")] = '\0';
		if ((wordlen = strlen(word)) == 0)
			continue;

		/* It's easier to forbid quotes and backslashes than to parse
		 * them.
		 */
		if (strcspn(word, "\"\\") != wordlen) {
			myerr(1, 0, "word contains a quote or a backslash: %s",
			    word);
		}

		if (printf("\t\"%s\",\n", word) < 0)
			myerr(1, 1, "printf");
	}

	return (0);
}

/* err: err() and errx() for a program that can't count on the system's err()
 * If `printerr` is set, print the string associated with the current errno
 * value.
 */
static int
myerr(int eval, int printerr, const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	if (printerr)
		fprintf(stderr, ": %s\n", strerror(errno));
	va_end(ap);
	exit(eval);
}
