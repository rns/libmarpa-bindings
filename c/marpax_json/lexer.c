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

/* Scan to the location  past a JSON number.
 * */
const unsigned char *
scan_number (const unsigned char *s, const unsigned char *end)
{
  unsigned char dig;

  if (*s == '-' || *s == '+')
    s++;
  if (s == end)
    return s;
  if (*s == '0')
    {
      s++;
      if (s == end)
  return s;
    }
  else
    {
      while ((unsigned char) (*s - '0') < 10)
  {
    s++;
    if (s == end)
      return s;
  }
    }
  if (*s == '.')
    {
      s++;
      if (s == end)
  return s;
      while ((unsigned) (*s - '0') < 10)
  {
    s++;
    if (s == end)
      return s;
  }
    }
  if (*s != 'e' && *s != 'E')
    return s;
  if (*s == '-' || *s == '+')
    s++;
  if (s == end)
    return s;
  while ((unsigned) (*s - '0') < 10)
    {
      s++;
      if (s == end)
  return s;
    }
  return s;
}

/* Scan to location past a JSON string.
 * Assumes we are pointing an initial double quote.
 * */
const unsigned char *
scan_string (const unsigned char *s, const unsigned char *end)
{
  s++;
  if (s == end)
    return s;
  while (*s != '"')
    {
      /* We are just looking for an unescaped double quote --
       * we don't try to deal with hex chars at this point.
       */
      if (*s == '\\')
  {
    s++;
    if (s == end)
      return s;
  }
      s++;
      if (s == end)
  return s;
    }
  s++;
  return s;
}

/* Scan to location past a literal constant
 * */
const unsigned char *
scan_constant (const unsigned char *target, const unsigned char *s,
         const unsigned char *end)
{
  const unsigned char *t = target + 1;
  s++;
  if (s == end)
    return s;
  while (*t)
    {
      if (*s != *t)
  return s;
      s++;
      if (s == end)
  return s;
      t++;
    }
  return s;
}

Input input_new(const char *filename)
{
  Input json;
  struct stat sb;
  unsigned char *p, *eof;

  int fd = open (filename, O_RDONLY);
  //initialize a stat for getting the filesize
  if (fstat (fd, &sb) == -1)
    {
      perror ("fstat");
      exit(1);
    }
  //do the actual mmap, and keep pointer to the first element
  p = (unsigned char *) mmap (0, sb.st_size, PROT_READ, MAP_SHARED, fd, 0);
  //something went wrong
  if (p == MAP_FAILED)
    {
      perror ("mmap");
      exit(1);
    }
  eof = p + sb.st_size;

  json.p = p;
  json.eof = eof;
  json.sb = sb;
  return json;
}

Marpa_Symbol_ID
lex(Input in)
{
  int i;
  unsigned char *p, *eof;
  struct stat sb;

  p = in.p;
  sb = in.sb;
  eof = in.eof;

  i = 0;
  eof = p + sb.st_size;

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
//      goto NEXT_TOKEN;
    default:
      printf ("lexer failed at char %d: '%c'", i, p[i]);
      exit (1);
  }
  return token;
}
