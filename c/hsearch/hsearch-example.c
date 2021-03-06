#include <stdio.h>
#include <stdlib.h>
#include "search.h"

static char *data[] = { "alpha", "bravo", "charlie", "delta",
    "echo", "foxtrot", "golf", "hotel", "india", "juliet",
    "kilo", "lima", "mike", "november", "oscar", "papa",
    "quebec", "romeo", "sierra", "tango", "uniform",
    "victor", "whisky", "x-ray", "yankee", "zulu"
};

int
main(void)
{
   ENTRY e, *ep;
   int i, key;

   hcreate(30);

   for (i = 0; i < 24; i++) {
       key = i + 100024;
       /* key is just an integer, instead of a
          pointer to something */
       e.key = (void *) &key;
       e.data = data[i];
       ep = hsearch(e, ENTER);
       /* there should be no failures */
       if (ep == NULL) {
           fprintf(stderr, "entry failed\n");
           exit(EXIT_FAILURE);
       }
   }

   /* print two entries from the table, and
      show that two are not in the table */
   for (i = 22; i < 26; i++) {
       key = i + 100024;
       e.key = (void *) &key;
       ep = hsearch(e, FIND);
       printf("%d -> %9.9s\n", key, ep ? ep->data : "NULL");
   }
   hdestroy();
   exit(EXIT_SUCCESS);
}
