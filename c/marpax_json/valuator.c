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

#include <stdio.h>
#include "marpa.h"

#include "json.h"

int
valuate(Input i, Marpa_Recognizer r, Marpa_Grammar g)
{
  unsigned char *p, *eof;

  p = i.p;
  eof = i.eof;

  {
    Marpa_Bocage bocage;
    Marpa_Order order;
    Marpa_Tree tree;

    bocage = marpa_b_new (r, -1);
    if (!bocage)
      {
        fail("marpa_b_new", g);
      }

    order = marpa_o_new (bocage);
    if (!order)
      {
        fail("marpa_o_new", g);
      }

    tree = marpa_t_new (order);
    if (!tree)
      {
        fail("marpa_t_new", g);
      }

    {
      Marpa_Value value = NULL;
      int column = 0;
      int tree_status;
      tree_status = marpa_t_next (tree);
      if (tree_status <= -1)
        {
          fail ("marpa_t_next", g);
        }

      value = marpa_v_new (tree);
      if (!value)
      {
        fail ("marpa_v_new", g);
      }

      while (1)
      {
        Marpa_Step_Type step_type = marpa_v_step (value);
        Marpa_Symbol_ID token;
        if (step_type < 0)
          {
            fail ("marpa_v_event", g);
          }
        if (step_type == MARPA_STEP_INACTIVE)
          {
            if (0)
              printf ("No more events\n");
            break;
          }
        if (step_type != MARPA_STEP_TOKEN)
          continue;
        token = marpa_v_token (value);
        if (1)
          {
            if (column > 60)
            {
              putchar ('\n');
              column = 0;
            }
            if (token == S_begin_array)
            {
              putchar ('[');
              column++;
              continue;
            }
            if (token == S_end_array)
            {
              putchar (']');
              column++;
              continue;
            }
            if (token == S_begin_object)
            {
              putchar ('{');
              column++;
              continue;
            }
            if (token == S_end_object)
            {
              putchar ('}');
              column++;
              continue;
            }
            if (token == S_name_separator)
            {
              putchar (':');
              column++;
              continue;
            }
            if (token == S_value_separator)
            {
              putchar (',');
              column++;
              continue;
            }
            if (token == S_null)
            {
              fputs ("undef", stdout);
              column += 5;
              continue;
            }
            if (token == S_true)
            {
              putchar ('1');
              column++;
              continue;
            }
            if (token == S_false)
            {
              putchar ('0');
              column++;
              continue;
            }
            if (token == S_number)
            {
              /* We added one to avoid zero
               * Now we must subtract it
               */
              int i;
              const int start_of_number = marpa_v_token_value (value) - 1;
              const int end_of_number =
                scan_number (p + start_of_number, eof) - (int)p;
              column += 2 + (end_of_number - start_of_number);

              /* We output numbers as Perl strings */
              putchar ('"');
              for (i = start_of_number; i < end_of_number; i++)
                {
                  putchar (p[i]);
                }
              putchar ('"');
              continue;
            }
            if (token == S_string)
            {
              /* We added one to avoid zero
               * Now we must subtract it, but we also
               * add one for the initial double quote
               */
              int i;
              const int start_of_string = marpa_v_token_value (value);
              /* Subtract one for the final double quote */
              const int end_of_string =
                (scan_string (p + start_of_string, eof) - (int)p) - 1;

              /* We add back the initial and final double quotes,
               * and increment the column accordingly.
               */
              column += 2;
              putchar ('"');
              i = start_of_string;
              while( i < end_of_string)
                {
                  const unsigned char ch0 = p[i++];
                  if (ch0 == '\\')
              {
                const unsigned char ch1 = p[i++];
                switch (ch1)
                  {
                  case '\\':
                  case '/':
                  case '"':
                  case 'b':
                  case 'f':
                  case 'n':
                  case 'r':
                  case 't':
                    /* explicit non-hex JSON escapes are the same
                     * as the Perl escapes */
                    column += 2;
                    putchar ('\\');
                    putchar (ch1);
                    continue;
                  case 'u':
                    {
                int digit;
                putchar ('x');
                putchar ('{');
                for (digit = 0; digit < 4; digit++)
                  {
                    const unsigned char hex_ch = p[i + digit];
                    if ((hex_ch >= 'a' && hex_ch <= 'f')
                  || (hex_ch >= 'A' && hex_ch <= 'F')
                  || (hex_ch >= '0' && hex_ch <= '9'))
                      {
                  printf
                    ("illegal char in JSON hex number at location %d (0x%x): '%c' ",
                     i, hex_ch, hex_ch);
                  exit (1);
                      }
                    putchar (hex_ch);
                  }
                putchar ('}');
                column += 7;
                i += 4;
                    }
                    continue;
                  default:
                    printf
                ("illegal escaped char in JSON input (0x%x):'%c' ",
                 i, p[i]);
                    exit (1);
                  }
              }

                  /* An unescaped JSON char, one that does not need Perl escaping */
                  if (ch0 == '_' || (ch0 >= '0' && ch0 <= '9')
                || (ch0 >= 'a' && ch0 <= 'z') || (ch0 >= 'A'
                        && ch0 <= 'Z'))
              {
                putchar (ch0);
                column++;
                continue;
              }
                  /* An unescaped JSON char,
                   * but one which quotemeta would escape for Perl */
                  putchar ('\\');
                  putchar (ch0);
                  column += 2;
                  continue;
                }
              putchar ('"');
              continue;
            }
                fprintf (stderr, "Unknown symbol %s at %d",
                   symbol_name (token), marpa_v_token_value (value) - 1);
                exit (1);
              }
          }
          if (column > 60)
          {
            putchar ('\n');
            column = 0;
          }
        }
      }
  putchar ('\n');

  return 0;
}
