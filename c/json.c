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

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/mman.h>
#include "marpa.h"

#include "grammar.h"
#include "recognizer.h"
#include "valuator.h"

#define MAX_RULES 12
int
main (int argc, char *argv[])
{
  Marpa_SG_Rule *rules[] = {
    marpa_sg_rule_new( "S_value", "S_false" ),
    marpa_sg_rule_new( "S_value", "S_null" ),
    marpa_sg_rule_new( "S_value", "S_true" ),
    marpa_sg_rule_new( "S_value", "S_object" ),
    marpa_sg_rule_new( "S_value", "S_array" ),
    marpa_sg_rule_new( "S_value", "S_number" ),
    marpa_sg_rule_new( "S_value", "S_string" ),

    marpa_sg_rule_new( "S_array", "S_begin_array", "S_array_contents", "S_end_array" ),
    marpa_sg_rule_new( "S_object", "S_begin_object", "S_object_contents", "S_end_object" ),

    marpa_sg_rule_new( "S_array_contents", "S_value", "S_value_separator", "0" ),
    marpa_sg_rule_new( "S_object_contents", "S_member", "S_value_separator", "0" ),

    marpa_sg_rule_new( "S_member", "S_string", "S_name_separator", "S_value" ),
  };
  Marpa_SG_Grammar *sg = marpa_sg_new(rules, sizeof(rules) / sizeof(Marpa_SG_Rule *));

  marpa_sg_show_symbols(sg);
  marpa_sg_show_rules(sg);

  S_begin_array = marpa_sg_symbol_id(sg, "S_begin_array");
  S_begin_object = marpa_sg_symbol_id(sg, "S_begin_object");
  S_end_array = marpa_sg_symbol_id(sg, "S_end_array");
  S_end_object = marpa_sg_symbol_id(sg, "S_end_object");
  S_name_separator = marpa_sg_symbol_id(sg, "S_name_separator");
  S_value_separator = marpa_sg_symbol_id(sg, "S_value_separator");
  S_member = marpa_sg_symbol_id(sg, "S_member");
  S_value = marpa_sg_symbol_id(sg, "S_value");
  S_false = marpa_sg_symbol_id(sg, "S_false");
  S_null = marpa_sg_symbol_id(sg, "S_null");
  S_true = marpa_sg_symbol_id(sg, "S_true");
  S_object = marpa_sg_symbol_id(sg, "S_object");
  S_array = marpa_sg_symbol_id(sg, "S_array");
  S_number = marpa_sg_symbol_id(sg, "S_number");
  S_string = marpa_sg_symbol_id(sg, "S_string");

  Input json = input_new(argv[1]);
  Marpa_Recognizer r = recognize(json, sg->g);
  valuate(json, r, sg->g);

  marpa_sg_rules_free(rules, sizeof(rules) / sizeof(Marpa_SG_Rule *));
  marpa_sg_free(sg);

  return 0;
}
