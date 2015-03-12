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

#include "json.h"
#include "sgrammar.h"

static Marpa_Recognizer
recognizer_new (Marpa_Grammar g)
{
  Marpa_Recognizer r;

  r = marpa_r_new (g);
  if (!r)
    {
      fail("marpa_r_new", g);
    }
  if (!marpa_r_start_input (r))
    {
      fail("marpa_r_start_input", g);
    }

  return r;
}

Marpa_Recognizer
recognize(Input in, Marpa_Grammar g)
{
  int i;
  unsigned char *p, *eof;
  struct stat sb;

  Marpa_Recognizer r = recognizer_new(g);

  p = in.p;
  sb = in.sb;
  eof = in.eof;

  i = 0;
  eof = p + sb.st_size;
  while (p + i < eof)
  {
    Marpa_Symbol_ID token;
    const int start_of_token = i;

    switch (p[i])
    {
      case '-':
      case '+':
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        i = scan_number (p + i, eof) - p;
        token = S_number;
        break;
      case '"':
        i = scan_string (p + i, eof) - p;
        token = S_string;
        break;
      case '[':
        token = S_begin_array;
        i++;
        break;
      case ']':
        token = S_end_array;
        i++;
        break;
      case '{':
        token = S_begin_object;
        i++;
        break;
      case '}':
        token = S_end_object;
        i++;
        break;
      case ',':
        token = S_value_separator;
        i++;
        break;
      case ':':
        token = S_name_separator;
        i++;
        break;
      case 'n':
        i = scan_constant ("null", (p + i), eof) - p;
        token = S_null;
        break;
      case ' ':
      case 0x09:
      case 0x0A:
      case 0x0D:
        i++;
        goto NEXT_TOKEN;
      default:
        printf ("lexer failed at char %d: '%c'", i, p[i]);
        exit (1);
    }

    /* Token value of zero is not allowed, so we add one */
    if (0)
      fprintf (stderr, "reading token %ld, %s\n",
         (long) token, symbol_name (token));

    int status = marpa_r_alternative (r, token, start_of_token + 1, 1);
    if (status != MARPA_ERR_NONE)
    {
      Marpa_Symbol_ID expected[20];
      int count_of_expected = marpa_r_terminals_expected (r, expected);
      int i;
      for (i = 0; i < count_of_expected; i++)
      {
        fprintf (stderr, "expecting symbol %ld, %s\n",
           (long) i, symbol_name (expected[i]));
      }
      marpa_g_error (g, NULL);
      fprintf (stderr,
         "marpa_alternative(%p,%ld,%s,%ld,1) returned %d", r,
         (long) token, symbol_name (token),
         (long) (start_of_token + 1), status);
      exit (1);
    }

    status = marpa_r_earleme_complete (r);
    if (status < 0)
    {
      fail ("marpa_earleme_complete", g);
    }
    NEXT_TOKEN:;
  }

  in.p = p;
  in.eof = eof;

  return r;
}
