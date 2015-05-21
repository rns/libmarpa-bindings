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

-- infer the external rule type (counted, precedenced, or BNF)
-- from the D2L table holding the rule's RHS
local function xrule_type(rhs)
  if type(rhs[1]) ~= "table" then
    return 'BNF'
  elseif
      #rhs == 4 and
      type(rhs[2]) == "table" and rhs[2][1] == 'quantifier' and
      type(rhs[3]) == "string" and ( rhs[3] == '%' or rhs[3] == '%%' )
    then
    return 'counted'
  else
    return 'precedenced'
  end
end

-- todo: iterators for RHS alternatives and symbols

-- grammar rules iterator based on next()
-- returns type of xrule after lhs and rhs
local function rule_next(grammar, lhs)
  local rhs
  lhs, rhs = next(grammar, lhs)
  if lhs == nil then return nil else
    return lhs, rhs, xrule_type(rhs)
  end
end

local function rules(grammar)
  return rule_next, grammar, nil
end

-- produce xrule and xsym databases for the KIR g1 and l0 grammars
function luif.G (grammar)
  assert( type(grammar) == "table", "grammar must be a table" )
  -- get grammar location
  local l = location()
  -- KHIL default grammars
  local g1 = { xrule = {}, xsym = {}, structural = true }
  local l0 = { xrule = {}, xsym = {} }
  -- iterate over rules (D2L tables)
  for lhs, rhs, xrule_type in rules(grammar) do
    -- wrap single-alternative RHS's and counted rules for
    -- the iteration over RHS alternatives below
    if xrule_type == 'BNF' or xrule_type == 'counted' then
      rhs = { rhs }
    end
    -- iterate over RHS alternatives
    p("\nRule type: ", xrule_type,", LHS: ", lhs)
    p(type(rhs[1]), #rhs)
    p(i(rhs))
    for rhs_i, rhs_alternative in ipairs(rhs) do
      p("RHSA", rhs_i, ": ", i(rhs_alternative))
      if xrule_type == 'counted' then
        p("counted")
      else
        -- iterate over RHS alternative’s symbols
        for rhs_alt_i = 1, #rhs_alternative do
          local rhs_alt_symbol = rhs_alternative[rhs_alt_i]
          p("RHSA symbol", rhs_alt_i, ": ", i(rhs_alt_symbol))
        end
      end
    end
  end
  return { g1 = g1, l0 = l0 }
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
