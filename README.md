libmarpa-bindings
=================

Mostly [libffi](https://sourceware.org/libffi/)-based bindings to [libmarpa](https://github.com/jeffreykegler/libmarpa). 

Status
------

libmarpa
  [Version 7.5.0 releases](https://github.com/rns/libmarpa-bindings/releases) (source code) built by `make dists` as described in [libmarpa's INSTALL file](https://github.com/jeffreykegler/libmarpa/blob/master/INSTALL).
  
Lua
  libmarpa C functions can be used from Lua via [luajit](http://luajit.org/luajit.html) 
  [FFI Library](http://luajit.org/ext_ffi.html).
  [JSON Parser]() with very basic handwritten lexer based on Lua patterns, mostly a port of [json.c]() to Lua.
  Interface (grammar, recognizer/lexer, valuator) is being written.
  
Python
  libmarpa C functions can be used from Python.
  Sample JSON parser
  
C#
  P/Invoke-based, MSVC 2010 Express
  just started: only version checking

