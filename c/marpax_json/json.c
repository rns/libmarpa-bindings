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

#include <stdio.h>
#include "marpa.h"
#include "json.h"

/* From RFC 7159 */
Marpa_Symbol_ID S_begin_array;
Marpa_Symbol_ID S_begin_object;
Marpa_Symbol_ID S_end_array;
Marpa_Symbol_ID S_end_object;
Marpa_Symbol_ID S_name_separator;
Marpa_Symbol_ID S_value_separator;
Marpa_Symbol_ID S_member;
Marpa_Symbol_ID S_value;
Marpa_Symbol_ID S_false;
Marpa_Symbol_ID S_null;
Marpa_Symbol_ID S_true;
Marpa_Symbol_ID S_object;
Marpa_Symbol_ID S_array;
Marpa_Symbol_ID S_number;
Marpa_Symbol_ID S_string;

/* Additional */
Marpa_Symbol_ID S_object_contents;
Marpa_Symbol_ID S_array_contents;

MarpaX_SG_Grammar *sg_json;

#define MAX_RULES 12
int
main (int argc, char *argv[])
{
  MarpaX_SG_Rule *rules[] = {
    marpax_sg_rule_new( "S_value", "S_false" ),
    marpax_sg_rule_new( "S_value", "S_null" ),
    marpax_sg_rule_new( "S_value", "S_true" ),
    marpax_sg_rule_new( "S_value", "S_object" ),
    marpax_sg_rule_new( "S_value", "S_array" ),
    marpax_sg_rule_new( "S_value", "S_number" ),
    marpax_sg_rule_new( "S_value", "S_string" ),

    marpax_sg_rule_new( "S_array", "S_begin_array", "S_array_contents", "S_end_array" ),
    marpax_sg_rule_new( "S_object", "S_begin_object", "S_object_contents", "S_end_object" ),

    marpax_sg_rule_new( "S_array_contents", "S_value", "S_value_separator", "0" ),
    marpax_sg_rule_new( "S_object_contents", "S_member", "S_value_separator", "0" ),

    marpax_sg_rule_new( "S_member", "S_string", "S_name_separator", "S_value" ),
  };
  MarpaX_SG_Grammar *sg_json = marpax_sg_new(rules, sizeof(rules) / sizeof(MarpaX_SG_Rule *));

  marpax_sg_show_symbols(sg_json);
  marpax_sg_show_rules(sg_json);

  S_begin_array = marpax_sg_symbol_id(sg_json, "S_begin_array");
  S_begin_object = marpax_sg_symbol_id(sg_json, "S_begin_object");
  S_end_array = marpax_sg_symbol_id(sg_json, "S_end_array");
  S_end_object = marpax_sg_symbol_id(sg_json, "S_end_object");
  S_name_separator = marpax_sg_symbol_id(sg_json, "S_name_separator");
  S_value_separator = marpax_sg_symbol_id(sg_json, "S_value_separator");
  S_member = marpax_sg_symbol_id(sg_json, "S_member");
  S_value = marpax_sg_symbol_id(sg_json, "S_value");
  S_false = marpax_sg_symbol_id(sg_json, "S_false");
  S_null = marpax_sg_symbol_id(sg_json, "S_null");
  S_true = marpax_sg_symbol_id(sg_json, "S_true");
  S_object = marpax_sg_symbol_id(sg_json, "S_object");
  S_array = marpax_sg_symbol_id(sg_json, "S_array");
  S_number = marpax_sg_symbol_id(sg_json, "S_number");
  S_string = marpax_sg_symbol_id(sg_json, "S_string");

  Input in = input_new(argv[1]);
  Marpa_Recognizer r = recognize(in, sg_json->g);
  valuate(in, r, sg_json->g);

  marpax_sg_rules_free(rules, sizeof(rules) / sizeof(MarpaX_SG_Rule *));
  marpax_sg_free(sg_json);

  return 0;
}
