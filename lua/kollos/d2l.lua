require 'DataDumper'

-- LUIF D2L calls mockup
local luif = {
  G = function(grammar) return grammar end,
  S = function(name) return "S:'" .. name .. "'" end,
  L = function(literal) return "L:'" .. literal .. "'" end,
  C = function(charclass) return "C:'" .. charclass .. "'" end,
  Q = function(quantifier) return "Q:'" .. quantifier .. "'" end,
  hide = function(...) return "hidden[ '" .. table.concat({...}, ' ') .. " ]" end,
  group = function(...) return "hidden[ '" .. table.concat({...}, ' ') .. " ]" end,
}

local S = luif.S
local L = luif.L
local C = luif.C
local Q = luif.Q

-- calculator

local calc = luif.G{
  Script = { S'Expression', Q'+', '%', L',' },
  Expression = {
    { S'Number' },
    { '|' , '(', S'Expression', ')' },
    { '||', S'Expression', L'**', S'Expression', { action = pow } },
    { '||', S'Expression', L'*', S'Expression', { action = mul } },
    { '|' , S'Expression', L'/', S'Expression', { action = div } },
    { '||', S'Expression', L'+', S'Expression', { action = add } },
    { '|' , S'Expression', L'-', S'Expression', { action = sub } },
  },
  Number = C'[0-9]+'
}

-- semantic actions
local pow = function (...) local arg={...} return arg[1] ^ arg[2] end
local mul = function (e1, e2) return e1 * e2 end
local div = function (e1, e2) return e1 / e2 end
local add = function (e1, e2) return e1 + e2 end
local sub = function (e1, e2) return e1 - e2 end

print(DataDumper(calc))

-- json
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

  members = { S'pair', Q'+', '%', S'comma' },

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

print(DataDumper(json))
