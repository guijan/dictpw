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

#include <err.h>
#include <stdio.h>
#include <string.h>

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
				err(1, "fgets");
			break;
		}

		word[strcspn(word, "\r\n")] = '\0';
		if ((wordlen = strlen(word)) == 0)
			continue;

		/* It's easier to forbid quotes and backslashes than to parse
		 * them.
		 */
		if (strcspn(word, "\"\\") != wordlen) {
			errx(1, "word contains a quote or a backslash: %s",
			    word);
		}

		if (printf("\t\"%s\",\n", word) < 0)
			err(1, "printf");
	}

	return (0);
}
