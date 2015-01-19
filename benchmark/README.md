About
=====
  
  Origin: https://github.com/jeffreykegler/libmarpa/tree/master/test/json
  
  Description: http://irclog.perlgeek.de/marpa/2014-08-31#i_9274289

Pre-reqs
--------

Perl

    JSON::XS
    JSON::PP

Lua

    lua-cjson
    dkjson

Running   
-------
  
    gcc json.c -lmarpa
    perl make_test_in.pl > test.in
    ./dotiming.sh && cat timings.out
