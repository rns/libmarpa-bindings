About
=====

A modified version of Jeffrey Kegler’s json benchmark 
[code](https://github.com/jeffreykegler/libmarpa/tree/master/test/json), 
[decription](http://irclog.perlgeek.de/marpa/2014-08-31#i_9274289)

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
