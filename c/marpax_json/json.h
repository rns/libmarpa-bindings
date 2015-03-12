/* Copyright 2015 Ruslan Shvedov
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
#ifndef JSON_H
#define JSON_H 1

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/mman.h>

#include "marpa.h"

#include "sgrammar.h"

/* Grammar */

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

extern MarpaX_SG_Grammar *sg_json;

/* Lexer */
const unsigned char *scan_number (const unsigned char *s, const unsigned char *end);
const unsigned char *scan_string (const unsigned char *s, const unsigned char *end);
const unsigned char *scan_constant
  (const unsigned char *target, const unsigned char *s, const unsigned char *end);

struct input {
  unsigned char *name, *p, *eof;
  struct stat sb;
};
typedef struct input Input;

Input input_new(const char *filename);

/* Recognizer */
Marpa_Recognizer recognize(Input input, Marpa_Grammar g);

/* Valuator */
int valuate(Input i, Marpa_Recognizer r, Marpa_Grammar g);

#endif
