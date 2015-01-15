libmarpa-bindings
=================

Mostly [libffi](https://sourceware.org/libffi/)-based bindings to [libmarpa](https://github.com/jeffreykegler/libmarpa) -- an ANSI C library, which implements [Marpa parsing algorithm](http://savage.net.au/Marpa.html) ("parse anything that can be written in BNF"). 

Status
======

libmarpa
--------

  [Version 7.5.0 releases](https://github.com/rns/libmarpa-bindings/releases) (source code) 
  built by `make dists` as described in 
  [libmarpa's INSTALL file](https://github.com/jeffreykegler/libmarpa/blob/master/INSTALL).
  
Lua
---

  libmarpa C functions can be called (and error-checked) from Lua via luajit FFI Library.

  [Sample JSON Parser](https://github.com/rns/libmarpa-bindings/blob/master/lua/json-libmarpa.lua), 
  mostly a port of [json.c](https://github.com/jeffreykegler/libmarpa/blob/master/test/json.c)
  with libmarpa bindings and with a very basic handwritten lexer based on Lua patterns.

  An interface (grammar, recognizer/lexer, valuator) is being written.
  
Python
------

  libmarpa C functions can be called (and error-checked) from Python via cffi.

  [Sample JSON Parser](https://github.com/rns/libmarpa-bindings/blob/master/python/json-libmarpa.py), 
  also a port of [json.c](https://github.com/jeffreykegler/libmarpa/blob/master/test/json.c) 
  with a handwritten lexer based on Python regexes.
  
C#
--

  Just started: only version checking via P/Invoke, MSVC 2010 Express
  

