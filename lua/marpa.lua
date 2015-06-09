-- debug helpers
local inspect = require 'inspect'
local i = inspect
local p = print

-- libmarpa binding
local lib   = require 'libmarpa'
local C     = lib.C
local ffi   = lib.ffi

-- components
local grammar = require 'grammar'
local recognizer = require 'recognizer'
local valuator = require 'valuator'

local marpa = {

  libmarpa = libmarpa,
  grammar = grammar,
  recognizer = recognizer,
  valuator = valuator,

  PROPER_SEPARATION = C.MARPA_PROPER_SEPARATION,
  KEEP_SEPARATION = C.MARPA_KEEP_SEPARATION,

  STEP_RULE = C.MARPA_STEP_RULE,
  STEP_TOKEN = C.MARPA_STEP_TOKEN,
  STEP_NULLING_SYMBOL = C.MARPA_STEP_NULLING_SYMBOL,
  STEP_TRACE = C.MARPA_STEP_TRACE,
  STEP_INACTIVE = C.MARPA_STEP_INACTIVE,
  STEP_INITIAL = C.MARPA_STEP_INITIAL,

  EVENT_NONE = C.MARPA_EVENT_NONE,
  EVENT_COUNTED_NULLABLE = C.MARPA_EVENT_COUNTED_NULLABLE,
  EVENT_EARLEY_ITEM_THRESHOLD = C.MARPA_EVENT_EARLEY_ITEM_THRESHOLD,
  EVENT_EXHAUSTED = C.MARPA_EVENT_EXHAUSTED,
  EVENT_LOOP_RULES = C.MARPA_EVENT_LOOP_RULES,
  EVENT_NULLING_TERMINAL = C.MARPA_EVENT_NULLING_TERMINAL,
  EVENT_SYMBOL_COMPLETED = C.MARPA_EVENT_SYMBOL_COMPLETED,
  EVENT_SYMBOL_EXPECTED = C.MARPA_EVENT_SYMBOL_EXPECTED,
  EVENT_SYMBOL_NULLED = C.MARPA_EVENT_SYMBOL_NULLED,
  EVENT_SYMBOL_PREDICTED = C.MARPA_EVENT_SYMBOL_PREDICTED,

}

local l = require 'location'

local function location()
  local info = debug.getinfo(3, "Sl")
  return l.new{
    blob = info.source,
    line = info.currentline
  }
end

-- bare literals other than '|', '||', '%', '%%', must produce errors

-- infer the rule type (sequence or BNF)
local function rule_type(rhs)
  if rhs[1] == 'sequence' then
    return 'sequence'
  else
    return 'BNF'
  end
end

-- possible todo: export rules(grammar), alternatives(rhs) and symbols(alternative) iterators

--[[
for lhs, rhs, rule_type in rules(grammar) do
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
-- returns type of rule after lhs and rhs
-- usage: for lhs, rhs, rule_type in rules(grammar) do ... end
--        for lhs, rhs in rules(grammar) do ... end

local function rule_next(grammar, lhs)
  local rhs
  lhs, rhs = next(grammar, lhs)
  if rhs then
    -- unwrap sequences
    if #rhs == 1 and type(rhs[1]) == 'table' and rhs[1][1] == 'sequence' then
      rhs = rhs[1]
    -- wrap single-alternative rhs
    elseif (type(rhs[1]) == 'string' and rhs[1] ~= 'sequence' ) or
      (type(rhs[1]) == 'table' and
        rhs[1][1] == 'literal' or rhs[1][1] == 'character class') then
      rhs = { rhs }
    end
  end
  if lhs then return lhs, rhs, rule_type(rhs) end
end

local function rules(grammar) return rule_next, grammar, nil end

-- iterator over alternatives in rhs
-- usage: for alternative_ix, alternative in alternatives(rhs) do ... end

local function alternative_next(rhs, i)
  i = i + 1
  local alternative = rhs[i]
  if alternative then
    return i, alternative
  end
end

local function alternatives(rhs) return alternative_next, rhs, 0 end

-- iterator over symbols in rhs alternative
-- usage: for symbol_ix, symbol in symbols(alternative) do ... end

local function symbol_next(rhs_alternative, i)
  i = i + 1
  local symbol = rhs_alternative[i]
  if symbol then
    -- wrap symbols
    if type(symbol) == 'string' then
      symbol = { 'symbol', symbol }
    end
    return i, symbol
  end
end

local function symbols(rhs_alternative) return symbol_next, rhs_alternative, 0 end

-- strip quantifier (last + or *, if any and return stripped string and quantifier
-- or nil and source string
local function quantifier(s)
  local last_char = string.sub(s, string.len(s))
  if last_char == '+' or last_char == '*' then
    return last_char, string.sub( s, 1, string.len(s) - 1 )
  end
  return nil, s
end

-- produce a { lhs => 'lhs_sym', rhs = { rhs_sym1, rhs_sym2 ... } } table
-- convert external grammar to lhs/rhs + sequences form
function marpa.intermediate_rules(grammar)

  -- extract grammar location
  local l = table.remove(grammar, #grammar)

  -- rules to be added to marpa grammar
  local grules = { }
  -- iterate over rules
  for lhs, rhs, rule_type in rules(grammar) do
    p(rule_type .. " rule:", lhs, "::=", i(rhs))
    -- single-alternative RHS
    if rule_type == 'sequence' then
      -- ...
      local _, seq = unpack(rhs)
      local item, quantifier, separator, flags = unpack(seq)
      local item_type = 'symbol'
      local location
      if type(item) == 'table' then
        item_type, item, location = unpack(item)
      end
      p("  Item("..item_type.."):", item) -- item can be symbol or, if table, literal or character class
      p("  Quantifier:", quantifier)
    elseif rule_type == 'BNF' then
    -- iterate over RHS alternatives
      for alternative_ix, alternative in alternatives(rhs) do
        p("  Alternative", alternative_ix, ":", i(alternative))
        -- iterate over RHS alternative’s symbols
        for symbol_ix, symbol_data in symbols(alternative) do
          p("    Symbol", symbol_ix, ":", i(symbol_data))
          -- ...
          local symbol_type, symbol, location = unpack(symbol_data)
          if symbol_type == 'symbol' then
            -- add sequence rules for implicit symbol sequences
            local quantifier = quantifier(symbol)
            if quantifier then
              p("      Implicit sequence:", symbol)
            end
          elseif symbol_type == 'literal' then
            -- todo: add symbols and rules for literal chars
            for char in symbol:gmatch('.') do
              p("      Literal character:", char)
            end
          elseif symbol_type == 'character class' then
            -- todo: add symbols and rules for charclass chars
            for char in symbol:gmatch('.') do
              p("      Class character  :", char)
            end
          end
        end
      end
    end -- rule_type
  end

  return grules
end

function marpa.grammar_new(grammar)

  -- extract grammar location
  local l = table.remove(grammar, #grammar)
  local grules = marpa.intermediate_rules(grammar)
  -- todo: add rules
  local g = marpa.grammar.new()
  return g
end

-- location():location() stringifies the location object
-- location() will be the location object proper
-- todo: remove stringified location()'s

-- produce rule and sym databases for the KIR g1 and l0 grammars
function marpa.G (grammar)
  assert( type(grammar) == "table", "grammar must be a table" )
  -- get grammar location
  local l = location()
  -- append location
  grammar[#grammar + 1] = l
  return grammar
end

function marpa.S (S_item, quantifier, S_separator, flags)
  return { "sequence", S_item, quantifier, S_separator, flags, location():location() }
end

function marpa.L (literal)
  return { "literal", literal, location():location() }
end

function marpa.C (charclass)
  -- check for and remove square parens
  local l = string.len(charclass)
  assert(string.sub(charclass, 1, 1) == '[' and
    (string.sub(charclass, l, l) == ']' or string.sub(charclass, l-1, l-1) == ']'),
      "character class " .. charclass .. " needs to be wrapped in square brackets")
  -- check for implicit charclass sequences
  local quantifier, class = quantifier(charclass)
  if quantifier then
    return marpa.S( marpa.C(class), quantifier, nil, nil )
  end
  return { "character class", string.sub(charclass, 2, -2), location():location() }
end

return marpa
