/*
 * Copyright (c) 2014 Łukasz Szpakowski.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <errno.h>
#include <getopt.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
	int optc;
	int is_delete = 0;
	int is_complement = 0;
	int is_squeeze_repeats = 0;
	char *set1;
	char *set2 = NULL;
	char *s_set;
	size_t set2_len = 0;
	int prev_c2 = -1, c;
	while((optc = getopt(argc, argv, "cCds")) != -1) {
		switch(optc) {
		case 'c':
		case 'C':
			is_complement = 1;
			break;
		case 'd':
			is_delete = 1;
			break;
		case 's':
			is_squeeze_repeats = 1;
			break;
		default:
			fprintf(stderr, "Usage: %s [-cCds] <set1> [<sed2>]\n", argv[0]);
			return 1;
		}
	}
	if(optind < argc) {
		set1 = argv[optind];
	} else {
		fprintf(stderr, "No set1\n");
		return 1;
	}
	if(!is_delete || (is_delete && is_squeeze_repeats)) {
		if(optind + 1 < argc) {
			set2 = argv[optind + 1];
		} else if(!is_squeeze_repeats || (is_delete && is_squeeze_repeats)) {
			fprintf(stderr, "No set2\n");
			return 1;
		}
	}
	s_set = set1;
	if(set2 != NULL) {
		s_set = set2;
		set2_len = strlen(set2);
	}
	errno = 0;
	while((c = getchar()) != -1) {
		int c2 = c;
		if(is_delete) {
			if((is_complement ? strchr(set1, c) == NULL : strchr(set1, c) != NULL)) c2 = -1;
		} else if(set2 != NULL) {
			if(is_complement) {
				if(strchr(set1, c) == NULL) c2 = set2[set2_len - 1];
			} else {
				char *s;
				if((s = strchr(set1, c)) != NULL) {
					size_t i = s - set1;
					c2 = set2[i < set2_len ? i : (set2_len - 1)];
				}
			}
		}
		if(c2 != -1) {
			if(is_squeeze_repeats) {
				if(set2 == NULL && is_complement) {
					if(strchr(s_set, c2) != NULL || prev_c2 != c2) putchar(c2);
				} else {
					if(strchr(s_set, c2) == NULL || prev_c2 != c2) putchar(c2);
				}
			} else
				putchar(c2);
			prev_c2 = c2;
		}
	}
	fflush(stdout);
	if(c == -1 && errno != 0) {
		fprintf(stderr, "%s\n", strerror(errno));
		return 1;
	}
	return 0;
}
