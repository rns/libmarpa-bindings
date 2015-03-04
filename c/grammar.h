/* Based on https://github.com/jeffreykegler/libmarpa/blob/master/test/json/json.c
 * Here is the copyright notice from that file:
 * Copyright 2015 Jeffrey Kegler
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
#ifndef GRAMMAR_H
#define GRAMMAR_H 1

#include <stdarg.h>
#include <stdio.h>

#include "marpa.h"

int fail (const char *s, Marpa_Grammar g);

/* From RFC 7159 */
extern Marpa_Symbol_ID S_begin_array;
extern Marpa_Symbol_ID S_begin_object;
extern Marpa_Symbol_ID S_end_array;
extern Marpa_Symbol_ID S_end_object;
extern Marpa_Symbol_ID S_name_separator;
extern Marpa_Symbol_ID S_value_separator;
extern Marpa_Symbol_ID S_member;
extern Marpa_Symbol_ID S_value;
extern Marpa_Symbol_ID S_false;
extern Marpa_Symbol_ID S_null;
extern Marpa_Symbol_ID S_true;
extern Marpa_Symbol_ID S_object;
extern Marpa_Symbol_ID S_array;
extern Marpa_Symbol_ID S_number;
extern Marpa_Symbol_ID S_string;

/* Additional */
extern Marpa_Symbol_ID S_object_contents;
extern Marpa_Symbol_ID S_array_contents;

/* For fatal error messages */
extern char error_buffer[80];

char *symbol_name (Marpa_Symbol_ID id);

struct marpa_sg_rule {
  int length;
  char **symbols;
};

typedef struct marpa_sg_rule Marpa_SG_Rule;

#define MAX_SYMBOLS 100

#define marpa_sg_rule_new(lhs, ...) marpa_sg_rule_new_func(lhs, ##__VA_ARGS__, (NULL))
Marpa_SG_Rule marpa_sg_rule_new_func(char* lhs, ...);

Marpa_Grammar marpa_sg_new(Marpa_SG_Rule *rules, int count);

int marpa_sg_rule_free(Marpa_SG_Rule rule);

#endif
