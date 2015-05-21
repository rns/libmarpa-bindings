local dumper = require 'dumper'
local d = dumper.dumper
local p = print

local luif = require 'luif'

local S = luif.S -- symbol
local L = luif.L -- literal
local C = luif.C -- character class
local Q = luif.Q -- sequence quantifier

--[[ Calculator --]]

-- semantic actions
local pow = function (...) local arg={...} return arg[1] ^ arg[2] end
local mul = function (e1, e2) return e1 * e2 end
local div = function (e1, e2) return e1 / e2 end
local add = function (e1, e2) return e1 + e2 end
local sub = function (e1, e2) return e1 - e2 end

local calc = luif.G{
  Script = { S'Expression', Q'+', '%', L',' },
  -- todo: bare literals for symbols, S{ item, quant, '%', sep } for sequences
  -- e.g. S{ 'Expression', '+', '%', L',' },
  -- bare literals except for '|', '||', '%', '%%',
  -- https://github.com/rns/kollos-luif-doc/issues/33
  Expression = {
    { S'Number' },
-- todo: this line { '|' , '(', S'Expression', ')' },
--       must produce "invalid bare literal" error in luif.G()

    { '|' , L'(', S'Expression', L')' },
    { '||', S'Expression', L'**', S'Expression', { action = pow } },
    { '||', S'Expression', L'*', S'Expression', { action = mul } },
    { '|' , S'Expression', L'/', S'Expression', { action = div } },
    { '||', S'Expression', L'+', S'Expression', { action = add } },
    { '|' , S'Expression', L'-', S'Expression', { action = sub } },
  },
  Number = C'[0-9]+'
}

p(d(calc))

--[[ JSON --]]
-- todo: add l0 rules from manual.md

local json = luif.G{

  json = {
    { S'object' },
    { S'array' }
  },

  object = {
    { luif.hide( L'{', L'}' ) },
    { luif.hide( L'{' ), S'members', luif.hide( L'}' ) }
  },

  members = { S'pair', Q'+', '%', S'comma' }, -- single alternative

  pair = {
    { S'string', luif.hide( L':' ), S'value' }
  },

  value = {
    { S'string' },
    { S'object' },
    { S'number' },
    { S'array' },
    { S'S_true' },
    { S'S_false' },
    { S'null' },
  },

  array = {
    { luif.hide( L'[', L']' ) },
    { luif.hide( L'[' ), S'elements', luif.hide( L']' ) },
  },

  elements = { S'value', Q'+', '%', S'comma' },

  string = { '[todo]' },

  comma = L',',

  S_true  = L'true', -- true and false are Lua keywords
  S_false = L'false',
  null  = L'null',

}

