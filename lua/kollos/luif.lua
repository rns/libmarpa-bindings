--[[
  Direct-to-Lua (D2L) prototype for the Kollos project’s KHIL
  Spec:
    D2L -- https://github.com/rns/kollos-luif-doc/blob/master/d2l/spec.md
    KIR -- https://github.com/rns/kollos-luif-doc/blob/master/etc/kir.md
--]]

-- dumping helpers
local dumper = require 'dumper'
local inspect = require 'inspect'
local i = inspect
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
    local xrule_type = '' -- counted, precedenced, or BNF
    -- infer type: counted, precedenced, BNF (single-alternative)
    -- wrap single-alternative RHS's and counted rules for
    -- the iteration over RHS alternatives below
    if type(rhs[1]) ~= "table" then
      rhs = { rhs }
      xrule_type = 'BNF'
    elseif
        #rhs == 4 and
        type(rhs[2]) == "table" and rhs[2][1] == 'quantifier' and
        type(rhs[3]) == "string" and ( rhs[3] == '%' or rhs[3] == '%%' )
      then
      rhs = { rhs }
      xrule_type = 'counted'
    else
      xrule_type = 'precedenced'
    end
    -- iterate over RHS alternatives
    p("\nRule type: ", xrule_type,", LHS: ", lhs)
    p(type(rhs[1]), #rhs)
    p(i(rhs))
    for rhs_i, rhs_alternative in ipairs(rhs) do
      p("RHS ", rhs_i, ": ", i(rhs_alternative))
    end
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
