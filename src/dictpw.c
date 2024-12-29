/*
 * Copyright (c) 2021-2022, 2024
 *     Guilherme Janczak <guilherme.janczak@yandex.com>
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
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "dict.h"
#include <caps.h>

/* Values based on conservative calculations in sec_pw_bits.bc */
enum {
	MINWORD = 3,
	DEFWORD = 4,
	MAXWORD = 8,
};

static int nflag = DEFWORD; /* How many words make up a password. */
static int hflag = 0; /* Has the help flag been used? */

static void usage(void);
static void fputs_noerr(const char *, FILE *);
static void fputc_noerr(int, FILE *);

int
main(int argc, char *argv[])
{
	int i;
	int ch;
	const char *errstr;

	caps();
	while ((ch = getopt(argc, argv, "hn:")) != -1) {
		switch (ch) {
		case 'h':
			hflag = 1;
			break;
		case 'n':
			nflag = strtonum(optarg, MINWORD, MAXWORD, &errstr);
			if (errstr != NULL) {
				warnx("password length is %s: %s", errstr,
				    optarg);
				usage();
				exit(1);
			}
			break;
		default:
			usage();
			exit(1);
			break;
		}
	}
	argv += optind;
	if (*argv != NULL) {
		fprintf(stderr, "%s: extraneous non-option argument%s: ",
		    getprogname(), argv[1] != NULL ? "s" : "");
		while (*argv != NULL) {
			fprintf(stderr, "'%s'", *argv);
			argv++;
			if (*argv != NULL)
				putc(' ', stderr);
			else
				putc('\n', stderr);
		}
		exit(1);
	}
	if (hflag) {
		usage();
		exit(0);
	}

	/*
	 * We can afford some pedantic code, but we can't afford a bad password,
	 * so error check the printing functions.
	 */
	for (i = 0; i++ < nflag;) {
		fputs_noerr(dict[arc4random_uniform(dictlen)], stdout);
		if (i < nflag)
			fputc_noerr('.', stdout);
		else
			fputc_noerr('\n', stdout);
	}
	errno = 0;
	if (fflush(stdout) == EOF)
		err(1, "fflush");
	exit(0);
}

static void
usage(void)
{
	fprintf(stderr, "usage:"
	    "\t%s [-h] [-n %d <= words <= %d]\n", getprogname(), MINWORD,
	    MAXWORD);
}

static void
fputs_noerr(const char *str, FILE *stream)
{
	errno = 0;
	if (fputs(str, stream) == EOF)
		err(1, "fputs");
}

static void
fputc_noerr(int c, FILE *stream)
{
	errno = 0;
	if (putc(c, stream) == EOF)
		err(1, "putc");
}
