--[[
  location object prototype for the Kollos project
  according to
  https://github.com/rns/kollos-luif-doc/blob/master/d2l/spec.md
--]]

-- dumping helpers
local dumper = require 'dumper'
local d = dumper.dumper
local p = print

local luif = {}

local l = require 'location'

local function location()
  local info = debug.getinfo(3, "Sl")
  return l.new{
    blob = info.source,
    line = info.currentline
  }
end

-- bare literals other than '|', '||', '%', '%%', must produce errors

function luif.G (grammar)
  assert( type(grammar) == "table", "grammar must be a table" )
  local l = location()
  for lhs, rhs in pairs(grammar) do
    p(lhs, d(rhs))
  end
  return grammar
end

function luif.S (name)
  return { "symbol", name, location():location() }
end

function luif.L (literal)
  return { "literal", literal, location():location() }
end

function luif.C (charclass)
  return { "character class", charclass, location():location() }
end

function luif.Q (quantifier)
  return { "quantifier", quantifier, location():location() }
end

function luif.hide (...)
  return { "hidden", {...}, location():location() }
end

function luif.group (...)
  return { "group", {...}, location():location() }
end

return luif
