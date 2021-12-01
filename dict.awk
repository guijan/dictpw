#!/usr/bin/awk

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

# This POSIX AWK script generates the C source file dict.c
# It takes a file containing newline-separated words, each word becomes an
# entry in the dictionary. No manual touch up is required after that.
#
# Example usage:
# awk -f dict.awk /usr/share/dict/words > dict.c

BEGIN{
	printf(                     \
	    "#include <inttypes.h>" \
	    "\n"                    \
	    "#include \"dict.h\"\n" \
	    "\n"                    \
	    "const char *const dict[] = {\n")
}

{
	printf("\t\"%s\",\n", $0)
}

END{
	printf(                                                       \
	    "};\n"                                                    \
	    "\n"                                                      \
	    "/* uint32_t because dictlen is used as the argument to " \
	    "arc4random_uniform. */\n"                                \
	    "const uint32_t dictlen = sizeof(dict) / sizeof(*dict);\n")
}
