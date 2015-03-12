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

#include <stdarg.h>
#include <stdio.h>
#include "marpa.h"

#include "sgrammar.h"

int
fail (const char *s, Marpa_Grammar g)
{
  Marpa_Error_Code errcode = marpa_g_error (g, NULL);
  printf ("%s returned %d: %s", s, errcode);
  exit (1);
}

void *check_ptr(void *ptr)
{
  if (ptr == NULL)
  {
    fprintf(stderr, "Out of memory.");
    exit(1);
  }
  return ptr;
}

MarpaX_SG_Rule *
marpax_sg_rule_new_func(char* lhs, ...)
{
  int ix;
  char *symbol;
  MarpaX_SG_Rule *rule;

  va_list args;
  va_start(args, lhs);

//  fprintf(stderr, "%s ", lhs);

  rule = check_ptr( malloc(sizeof(MarpaX_SG_Rule)) );

  rule->symbols = check_ptr( malloc(sizeof(char *)) );
  rule->symbols[0] = lhs;

  for (ix = 1; ix < 1000; ix++)
  {
    symbol = va_arg(args, char *);
    if (symbol == NULL)
      break;

    rule->symbols = check_ptr( realloc( rule->symbols, ( ix + 1 ) * sizeof(char *)) );
    rule->symbols[ix] = symbol;

//    fprintf(stderr, "%s ", symbol);
  }
//  fprintf(stderr, "\n");
  va_end(args);

  rule->length = ix;

  return rule;
}

int
marpax_sg_rule_free(MarpaX_SG_Rule *rule)
{
  free(rule->symbols);
}

int marpax_sg_rule_is_sequence(MarpaX_SG_Rule *rule)
{
  return ( rule->length == 4
       && ( ( strcmp(rule->symbols[3], "0") == 0 )
            || ( strcmp(rule->symbols[3], "1") ) == 0 ) );
}

Marpa_Symbol_ID
marpax_sg_symbol_id(MarpaX_SG_Grammar *sg, const char *name)
{
  int i;
  for (i = 0; i < sg->symbol_table_length; i++)
  {
    if (strcmp(sg->st[i].name, name) == 0)
    {
      return i;
    }
  }
  return -1;
}

int
marpax_sg_show_symbols(MarpaX_SG_Grammar *sg)
{
  int i;
  Marpa_Symbol_ID S_highest = marpa_g_highest_symbol_id(sg->g);
  for (i = 0; i <= S_highest; i++)
  {
    char *name = marpax_sg_symbol(sg, i);
    Marpa_Symbol_ID id = marpax_sg_symbol_id(sg, name);
    fprintf(stderr, "S%d: %s of %d\n", i, name, S_highest+1);
  }
}

int
marpax_sg_show_rules(MarpaX_SG_Grammar *sg)
{
  Marpa_Rule_ID R_current;
  Marpa_Rule_ID R_highest = marpa_g_highest_rule_id(sg->g);
  for (R_current = 0; R_current <= R_highest; R_current++)
  {
    Marpa_Symbol_ID S_id = marpa_g_rule_lhs(sg->g, R_current);
    fprintf(stderr, "%s ::= ", marpax_sg_symbol(sg, S_id));
    int sequence_min = marpa_g_sequence_min(sg->g, R_current);
    int length = marpa_g_rule_length(sg->g, R_current);
    int i;
    for (i = 0; i < length; i++)
    {
      fprintf(stderr, "%s ", marpax_sg_symbol(sg, marpa_g_rule_rhs(sg->g, R_current, i)));
    }
    if (sequence_min != -1)
    {
      fprintf(stderr, "min: %d, proper: %d, separator: %s", sequence_min,
      marpa_g_rule_is_proper_separation(sg->g, R_current),
      marpax_sg_symbol(sg, marpa_g_sequence_separator(sg->g, R_current)) );
    }
    fprintf(stderr, "\n");
  }
}

char *
marpax_sg_symbol(MarpaX_SG_Grammar *sg, Marpa_Symbol_ID S_id)
{
  int i;
  for (i = 0; i < sg->symbol_table_length; i++)
  {
    if (sg->st[i].id == S_id)
    {
      return sg->st[i].name;
    }
  }
  return NULL;
}

Marpa_Symbol_ID
marpax_sg_symbol_new(MarpaX_SG_Grammar *sg, char *name)
{
  Marpa_Symbol_ID S_id = marpax_sg_symbol_id(sg, name);
  if (S_id < 0)
  {
    ((S_id = marpa_g_symbol_new(sg->g)) >= 0) || fail ("marpa_g_symbol_new", sg->g);
    sg->symbol_table_length++;
    if (sg->symbol_table_length == 1)
    {
      sg->st = check_ptr(malloc(sg->symbol_table_length * sizeof(MarpaX_SG_Symbol_Table_Entry)));
    }
    else
    {
      sg->st = check_ptr(realloc(sg->st, sg->symbol_table_length * sizeof(MarpaX_SG_Symbol_Table_Entry)));
    }
    sg->st[sg->symbol_table_length - 1].name = name;
    sg->st[sg->symbol_table_length - 1].id = S_id;
  }
  return S_id;
}

MarpaX_SG_Grammar *
marpax_sg_new(MarpaX_SG_Rule *rules[], int count)
{
  int rule_ix;

  Marpa_Config marpa_configuration;
  Marpa_Grammar g;

  MarpaX_SG_Grammar *sg = check_ptr(malloc(sizeof(MarpaX_SG_Grammar)));
  sg->symbol_table_length = 0;

  marpa_c_init (&marpa_configuration);
  g = marpa_g_new (&marpa_configuration);
  if (!g)
    {
      Marpa_Error_Code errcode =
        marpa_c_error (&marpa_configuration, NULL);
      printf ("marpa_g_new returned %d: %s", errcode);
      exit (1);
    }
  sg->g = g;

  for (rule_ix = 0; rule_ix < count; rule_ix++)
  {
    MarpaX_SG_Rule *rule = rules[rule_ix];

    int rule_is_sequence = marpax_sg_rule_is_sequence (rule);

    int symbol_count = rule_is_sequence ? rule->length - 1 : rule->length;
    int symbol_ix;
    for (symbol_ix = 0; symbol_ix < symbol_count; symbol_ix++)
    {
      Marpa_Symbol_ID S_id = marpax_sg_symbol_new(sg, rule->symbols[symbol_ix]);
//      fprintf(stderr, "Adding symbol %d: %s:%d.\n", symbol_ix, marpax_sg_symbol(sg, S_id), S_id);
    }

    if ( rule_is_sequence )
    {
      int sequence_min = rule->symbols[3][0] == '0' ? 0 : 1;
      (marpa_g_sequence_new (g,
         marpax_sg_symbol_id(sg, rule->symbols[0]),
         marpax_sg_symbol_id(sg, rule->symbols[1]),
         marpax_sg_symbol_id(sg, rule->symbols[2]),
         sequence_min,
         MARPA_PROPER_SEPARATION) >= 0) || fail ("marpa_g_sequence_new", g);
    }
    else
    {
      Marpa_Symbol_ID *rhs = check_ptr(malloc((symbol_count - 1) * sizeof(Marpa_Symbol_ID)));
      for (symbol_ix = 1; symbol_ix < symbol_count; symbol_ix++)
      {
        rhs[symbol_ix - 1] = marpax_sg_symbol_id(sg, rule->symbols[symbol_ix]);
      }
      (marpa_g_rule_new (g, marpax_sg_symbol_id(sg, rule->symbols[0]), rhs, symbol_count - 1) >= 0)
        || fail ("marpa_g_rule_new", g);
      free(rhs);
    }
//    fprintf(stderr, "Rule %d of %d, %d symbols:\n", rule_ix, count, rules[rule_ix]->length );
  }

  (marpa_g_start_symbol_set (g, marpax_sg_symbol_id(sg, "S_value")) >= 0)
    || fail ("marpa_g_start_symbol_set", g);
  if (marpa_g_precompute (g) < 0)
    {
      fail("marpa_g_precompute", g);
    }

  return sg;
}

int
marpax_sg_free(MarpaX_SG_Grammar *sg)
{
  free(sg->st);
  free(sg);
}

int
marpax_sg_rules_free(MarpaX_SG_Rule *rules[], int count)
{
  int rule_ix;
  for (rule_ix = 0; rule_ix < count; rule_ix++){
    marpax_sg_rule_free (rules[rule_ix]);
  }
  return 0;
}
