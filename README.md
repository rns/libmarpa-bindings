libmarpa-bindings
=================

Mostly [libffi](https://sourceware.org/libffi/)-based bindings to [libmarpa](https://github.com/jeffreykegler/libmarpa) -- an ANSI C library, which implements [Marpa parsing algorithm](http://savage.net.au/Marpa.html) ("parse anything that can be written in BNF"). 

Status
======

libmarpa
--------

  [Version 7.5.0 releases](https://github.com/rns/libmarpa-bindings/releases) (source code) built by `make dists` as described in [libmarpa's INSTALL file](https://github.com/jeffreykegler/libmarpa/blob/master/INSTALL).
  
Lua
---

  libmarpa C functions can be called (and error-checked) from Lua via [luajit](http://luajit.org/luajit.html) 
  [FFI Library](http://luajit.org/ext_ffi.html).

  [Sample JSON Parser](https://github.com/rns/libmarpa-bindings/blob/master/lua/json-libmarpa.lua) with handwritten lexer based on Python regexes, mostly a port of [json.c](https://github.com/jeffreykegler/libmarpa/blob/master/test/json.c) to Lua.

  An interface (grammar, recognizer/lexer, valuator) is being written.
  
Python
------

  libmarpa C functions can be called (and error-checked) from Python via cffi.

  [Sample JSON Parser]() with very basic handwritten lexer based on Lua patterns, mostly a port of [json.c](https://github.com/jeffreykegler/libmarpa/blob/master/test/json.c) to Lua.
  
C#
  just started: only version checking via P/Invoke, MSVC 2010 Express
  

