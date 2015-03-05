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

#include "lexer.h"

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

  json.p = p;
  json.eof = eof;
  json.sb = sb;
  return json;
}

