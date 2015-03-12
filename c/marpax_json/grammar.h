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

struct marpax_sg_rule {
  int length;
  char **symbols;
};
typedef struct marpax_sg_rule MarpaX_SG_Rule;

struct marpax_sg_symbol_table_entry {
  Marpa_Symbol_ID id;
  char *name;
};
typedef struct marpax_sg_symbol_table_entry MarpaX_SG_Symbol_Table_Entry;

struct marpax_sg_grammar {
  Marpa_Grammar g;
  int symbol_table_length;
  MarpaX_SG_Symbol_Table_Entry *st;
};
typedef struct marpax_sg_grammar MarpaX_SG_Grammar;

#define marpax_sg_rule_new(lhs, ...) marpax_sg_rule_new_func(lhs, ##__VA_ARGS__, (NULL))
MarpaX_SG_Rule *marpax_sg_rule_new_func(char* lhs, ...);

MarpaX_SG_Grammar *marpax_sg_new(MarpaX_SG_Rule *rules[], int count);
int marpax_sg_free(MarpaX_SG_Grammar *);

char *marpax_sg_symbol(MarpaX_SG_Grammar *sg, Marpa_Symbol_ID S_id);
Marpa_Symbol_ID marpax_sg_symbol_new(MarpaX_SG_Grammar *sg, char *name);

int marpax_sg_rules_free(MarpaX_SG_Rule *rules[], int count);
int marpax_sg_rule_free(MarpaX_SG_Rule *rule);

int marpax_sg_show_rules(MarpaX_SG_Grammar *sg);
int marpax_sg_show_symbols(MarpaX_SG_Grammar *sg);

#endif
