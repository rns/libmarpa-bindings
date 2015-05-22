local t = require 'Test.More'

package.path = "../?.lua;../../?.lua;" .. package.path

local dumper = require 'dumper'
local d = dumper.dumper
local p = print

local luif = require 'luif'

local S = luif.S -- symbol
local L = luif.L -- literal
local C = luif.C -- character class
local R = luif.R -- rule (location marker)

--[[ Calculator --]]

-- semantic actions
local pow = function (...) local arg={...} return arg[1] ^ arg[2] end
local mul = function (e1, e2) return e1 * e2 end
local div = function (e1, e2) return e1 / e2 end
local add = function (e1, e2) return e1 + e2 end
local sub = function (e1, e2) return e1 - e2 end

-- todo: this line '|' , { '(', 'Expression', ')' },
--       must produce "invalid bare literal" error in luif.G()

local calc = luif.G{
  Script = S{ 'Expression', '+', '%', L',' },
  -- todo: bare literals for symbols, S{ item, quant, '%', sep } for sequences
  -- e.g. S{ 'Expression', '+', '%', L',' },
  -- bare literals except for '|', '||', '%', '%%',
  -- https://github.com/rns/kollos-luif-doc/issues/33

--[[ todo: discuss '||', { ... }, '|', { ... } syntax for precedenced rules

  Expression = {
          { 'Number' },
     '|', { L'(', 'Expression', L')' },
    '||', { 'Expression', L'**', 'Expression', { action = pow } },
    '||', { 'Expression', L'*', 'Expression', { action = mul } },
    '|' , { 'Expression', L'/', 'Expression', { action = div } },
    '||', { 'Expression', L'+', 'Expression', { action = add } },
     '|', { 'Expression', L'-', 'Expression', { action = sub } },

  Expression = {
          { 'Number' },
          { L'(', 'Expression', L')' },
          { 'Expression', L'**', 'Expression', { action = pow } },
    '||', { 'Expression', L'*', 'Expression', { action = mul } },
          { 'Expression', L'/', 'Expression', { action = div } },
    '||', { 'Expression', L'+', 'Expression', { action = add } },
          { 'Expression', L'-', 'Expression', { action = sub } },
    what is a good name for '||'?
    http://www.fileformat.info/info/unicode/block/mathematical_operators/utf8test.htm
    unicode char? http://lua-users.org/wiki/UnicodeIdentifers
    lua can support utf8 identifiers and we embed lua so perhaps ...
  },
--]]

  Expression = {
    { 'Number' },
    {  '|', L'(', 'Expression', L')' },
    { '||', 'Expression', L'**', 'Expression', { action = pow } },
    { '||', 'Expression', L'*', 'Expression', { action = mul } },
    { '|' , 'Expression', L'/', 'Expression', { action = div } },
    { '||', 'Expression', L'+', 'Expression', { action = add } },
    {  '|', 'Expression', L'-', 'Expression', { action = sub } },
  },

  lexer = luif.G{
    Number = C'[0-9]+'
  }

}

local calc_g = luif.grammar_new('calc', calc)

--[[ JSON --]]
-- todo: add l0 rules from manual.md

local json = luif.G{

  json = {
    { 'object' },
    { 'array' }
  },

  object = {
    { luif.hide( L'{', L'}' ) },
    { luif.hide( L'{' ), 'member', luif.hide( L'}' ) }
  },

  members = S{ 'pair', '+', '%', 'comma' }, -- single alternative

  pair = {
    { 'string', luif.hide( L':' ), 'value' }
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
    { luif.hide( L'[', L']' ) },
    { luif.hide( L'[' ), 'element', luif.hide( L']' ) },
  },

  elements = S{ 'value', '+', '%', 'comma' },

  string = R{ 'lstring' },

  lexer = luif.G{

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

local json_g = luif.grammar_new('json', json)
