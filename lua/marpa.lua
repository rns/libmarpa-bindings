-- libmarpa binding
local lib   = require 'libmarpa'
local C     = lib.C
local ffi   = lib.ffi

-- components
local grammar = require 'grammar'
local recognizer = require 'recognizer'
local valuator = require 'valuator'

return { libmarpa = libmarpa, grammar = grammar, recognizer = recognizer, valuator = valuator }
