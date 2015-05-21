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

-- possible todo: export rules(grammar), alternatives(rhs) and symbols(alternative) iterators

--[[
for lhs, rhs, xrule_type in rules(grammar) do
  ...
  for alternative_ix, alternative in alternatives(rhs) do
    ...
    for symbol_ix, symbol in symbols(alternative) do
      ...
    end
  end
end
--]]

-- for symbol_ix, symbol in symbols(alternative)

-- grammar rules iterator based on next()
-- returns type of xrule after lhs and rhs
-- usage: for lhs, rhs, xrule_type in rules(grammar) do ... end
--        for lhs, rhs in rules(grammar) do ... end

local function rule_next(grammar, lhs)
  local rhs
  lhs, rhs = next(grammar, lhs)
  if lhs then return lhs, rhs, xrule_type(rhs) end
end

local function rules(grammar) return rule_next, grammar, nil end

-- iterator over alternatives in rhs
-- usage: for alternative_ix, alternative in alternatives(rhs) do ... end

local function alternative_next(rhs, i)
  i = i + 1
  local alternative = rhs[i]
  if alternative then return i, alternative end
end

local function alternatives(rhs) return alternative_next, rhs, 0 end

-- iterator over symbols in rhs alternative
-- usage: for symbol_ix, symbol in symbols(alternative) do ... end

local function symbol_next(rhs_alternative, i)
  i = i + 1
  local symbol = rhs_alternative[i]
  if symbol then return i, symbol end
end

local function symbols(rhs_alternative) return symbol_next, rhs_alternative, 0 end

-- get adverbs from the rule
-- return nil if no adverb is defined
local function adverbs(rhs_alternative)
  local len = #rhs_alternative
  if type( rhs_alternative[len] ) == 'table' and
     rhs_alternative[len][1] ~= 'symbol' and
     rhs_alternative[len][1] ~= 'literal' and
     rhs_alternative[len][1] ~= 'hidden' and
     rhs_alternative[len][1] ~= 'character class' and
     rhs_alternative[len][1] ~= 'quantifier'
     then
    return table.remove (rhs_alternative, len)
  end
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
    p(xrule_type, "rule:", lhs, "::=", i(rhs))
    -- single-alternative RHS
    if xrule_type == 'counted' then
      -- ...
    elseif xrule_type == 'BNF' then
      -- ...
    else
    -- iterate over RHS alternatives
      for alternative_ix, alternative in alternatives(rhs) do
        local adverbs = adverbs(alternative)
        p("  Alternative", alternative_ix, ":", i(alternative))
        if adverbs then
          p("  adverbs = ", i(adverbs))
          -- ...
        end
        -- iterate over RHS alternative’s symbols
        for symbol_ix, symbol in symbols(alternative) do
          p("    Symbol", symbol_ix, ":", i(symbol))
          -- ...
        end
      end
    end -- xrule_type
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
