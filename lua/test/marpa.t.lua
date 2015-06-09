local t = require 'Test.More'

package.path = "../?.lua;../../?.lua;" .. package.path

local marpa = require 'marpa'

local R = marpa.R -- rule (location marker)
local S = marpa.S -- sequence
local L = marpa.L -- literal
local C = marpa.C -- character class

--[[ Calculator --]]

-- todo: this line '|' , { '(', 'Expression', ')' },
--       must produce "invalid bare literal" error in marpa.G()
-- symbol names without alphanumeric characters must at least produce a warning

local calc = marpa.G{

  Script = S{ 'Expression', '+', L',' }, -- explicit sequence

  Expression = {
    { 'Number' },
    { L'(', 'Expression', L')' },
    { 'Expression', L'**', 'Expression' },
    { 'Expression', L'*', 'Expression' },
    { 'Expression', L'/', 'Expression' },
    { 'Expression', L'+', 'Expression' },
    { 'Expression', L'-', 'Expression' },
  },

  Number = { C'[0-9]+' } -- implicit sequences; todo:

}

local calc_g = marpa.grammar_new('calc', calc)

--[[ JSON --]]

local json = marpa.G{

  json = {
    { 'object' },
    { 'array' }
  },

  object = {
    { L'{', L'}' },
    { L'{', 'member', L'}' }
  },

  members = S{ 'pair', '+', 'comma' },

  pair = { 'string', L':', 'value' },  -- single alternative

  value = {
    { 'string' },
    { 'object' },
    { 'number' },
    { 'array' },
    { 'true' },
    { 'false' },
    { 'null' },
  },

  array = {
    { L'[', L']' },
    { L'[', 'element', L']' },
  },

  elements = S{ 'value', '+', 'comma' },

  -- todo: handle this single-alternative, single-symbol rules
  string = R{ 'lstring' }, -- optional, adds source file/line to the rule

  -- lexical
  comma = { L',' },

  -- todo: handle this single-alternative, single-symbol rules
  ["true"]  = { L'true' }, -- true and false are Lua keywords
  ["false"] = { L'false' },
  null  = { L'null' },

  number = {
    { 'int' },
    { 'int', 'frac' },
    { 'int', 'exp' },
    { 'int', 'frac', 'exp' }
  },

  int = {
    { 'digits' },
    { L'-', 'digits' }
  },

  digits = { C'[0-9]+' }, -- implicit sequence, no separator

  frac = { L'.', 'digits' },

  exp = { 'e', 'digits' },

  e = { { L'e' }, { L'e+' }, { L'e-' }, { L'E' }, { L'E+' }, { L'E-' } },

  lstring = { 'quote', 'in_string', 'quote' },

  quote = { C'["]' }, -- can also be L'"'

  -- todo: handle this single-alternative, single-symbol rules
  in_string = { 'in_string_char*'  },

  in_string_char = { { C'[^"]' }, { L'\\"' } },

  whitespace = { C'[\009\010\013\032]+' },

} -- json grammar

local json_g = marpa.grammar_new('json', json)

done_testing()
