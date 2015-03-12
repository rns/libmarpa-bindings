/* search.h -- declarations for System V style searching functions.
   Copyright (C) 1995, 1996 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

#ifndef _SEARCH_H
#define _SEARCH_H 1

#include "cdefs.h"

#define __need_size_t
#define __need_NULL
#include <stddef.h>

__BEGIN_DECLS

/* For use with hsearch(3).  */
#ifndef __COMPAR_FN_T
#define __COMPAR_FN_T
typedef int (*__compar_fn_t) __P ((__const __ptr_t, __const __ptr_t));
#endif

/* Action which shall be performed in the call the hsearch.  */
typedef enum
  {
    FIND,
    ENTER
  }
ACTION;

typedef struct entry
  {
    char *key;
    char *data;
  }
ENTRY;

/* Opaque type for internal use.  */
struct _ENTRY;

/* Data type for reentrant functions.  */
struct hsearch_data
  {
    struct _ENTRY *table;
    unsigned int size;
    unsigned int filled;
  };

/* Family of hash table handling functions.  The functions also have
   reentrant counterparts ending with _r.  */
extern ENTRY *hsearch __P ((ENTRY __item, ACTION __action));
extern int hcreate __P ((size_t __nel));
extern void hdestroy __P ((void));

extern int hsearch_r __P ((ENTRY __item, ACTION __action, ENTRY **__retval,
         struct hsearch_data *__htab));
extern int hcreate_r __P ((size_t __nel, struct hsearch_data *htab));
extern void hdestroy_r __P ((struct hsearch_data *htab));

__END_DECLS

#endif /* search.h */
