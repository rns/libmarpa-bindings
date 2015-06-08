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

local calc = marpa.G{

  Script = S{ 'Expression', '+', '%', L',' },

  Expression = {
    { 'Number' },
    { L'(', 'Expression', L')' },
    { 'Expression', L'**', 'Expression' },
    { 'Expression', L'*', 'Expression' },
    { 'Expression', L'/', 'Expression' },
    { 'Expression', L'+', 'Expression' },
    { 'Expression', L'-', 'Expression' },
  },

  Number = C'[0-9]+'

}

local calc_g = marpa.grammar_new('calc', calc)

--[[ JSON --]]

local json = marpa.G{

  json = {
    { 'object' },
    { 'array' }
  },

  object = {
    { marpa.hide( L'{', L'}' ) },
    { marpa.hide( L'{' ), 'member', marpa.hide( L'}' ) }
  },

  members = S{ 'pair', '+', '%', 'comma' }, -- single alternative

  pair = {
    { 'string', marpa.hide( L':' ), 'value' }
  },

  value = {
    { 'string' },
    { 'object' },
    { 'number' },
    { 'array' },
    { 'S_true' },
    { 'S_false' },
    { 'null' },
  },

  array = {
    { marpa.hide( L'[', L']' ) },
    { marpa.hide( L'[' ), 'element', marpa.hide( L']' ) },
  },

  elements = S{ 'value', '+', '%', 'comma' },

  string = R{ 'lstring' }, -- optional, adds source file/line to the rule

  lexer = marpa.G{

    comma = { L',' },

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

    -- Lua sequence pattern -- digits = { C'[%d]+' } -- can be used
    digits = S{ C'[%s]', '+', '%' }, -- no sequence separator? todo: check if it is allowed

    frac = { L'.', 'digits' },

    exp = { 'e', 'digits' },

    e = { { L'e' }, { L'e+' }, { L'e-' }, { L'E' }, { L'E+' }, { L'E-' } },

    lstring = { 'quote', 'in_string', 'quote' },

    quote = { C'["]' }, -- can also be L'"'

    in_string = S{ 'in_string_char', '*', '%'  },  -- the above sequence todo applies

    in_string_char = { { C'[^"]' }, { L'"' } },

    -- Lua sequence pattern -- whitespace = { C'[%s]+' } -- can be used
    whitespace = S{ C'[%s]', '+', '%' }, -- the above sequence todo applies

  } -- lexer

} -- json grammar

local json_g = marpa.grammar_new('json', json)

done_testing()
