#!/usr/bin/lua
require 'Test.More'

require 'os'

package.path = '../?.lua;../../?.lua;' .. package.path

local dumper = require 'dumper'

-- Lua THIF
local marpa = require 'marpa'

--
-- grammar spec
--

-- JSON LUIF grammar for Kollos,
--   https://github.com/jeffreykegler/kollos/blob/master/working/json.luif

-- todo: convert to D2L

local jg = {
  parser = {
    _start_symbol = 'json',
    json = {
      { 'object' },
      { 'array' }
    },
    object = {
      { 'lcurly', 'rcurly' },
      { 'lcurly', 'members', 'rcurly' },
    },
    members = {
      { 'pair', { proper = true, quantifier = '+', separator = 'comma' } }
    },
    pair = {
      { 'string', 'colon', 'value' }
    },
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
      { 'lsquare', 'rsquare' },
      { 'lsquare', 'elements', 'rsquare' },
    },
    elements = {
      { 'value', { proper = true, quantifier = '+', separator = 'comma' } },
    },
  },
  -- lexer rules (order is important)
  lexer = {
    { "{", "lcurly" },
    { "}", "rcurly" },
    { "%[", "lsquare" },
    { "%]", "rsquare" },
    { ",", "comma" },
    { ":", "colon" },
    { '"[^"]+"', "string" },
    { "-?[%d]+[.%d+]*", "number" },
    { "true", "true" },
    { "false", "false" },
    { "null", "null" },
    { '[ \t]+', 'WHITESPACE' },  -- Skip over spaces and tabs
    { "\n", 'NEWLINE', },  -- Line endings
    { '.', 'MISMATCH', }   -- Any other character
  },
}

--
-- grammar construction
--

local g = marpa.grammar.new()

-- parser rules
assert( type(jg["lexer"]) == "table", [[Grammar spec must have a table under "lexer" key]])
for lhs, rhs in pairs(jg["parser"]) do
  -- handle start symbol
  if lhs == '_start_symbol' then
    local S_start = g:symbol_new(rhs)
    g:start_symbol_set(S_start)
  else
    -- add lhs symbol to the grammar
    local S_lhs = g:symbol_new(lhs)
    -- add rhs symbol to grammar
    assert( type(rhs) == "table", "rhs must be a table of strings representing symbols")
    for _, rhs_alternative in ipairs(rhs) do
      assert( type(rhs_alternative) == "table", "rhs_alternative must be a table of strings representing symbols")
      -- extract rule's adverbs, if any
      local adverbs = {}
      if type(rhs_alternative[#rhs_alternative]) == "table" then
        adverbs = table.remove(rhs_alternative) -- pop off the table
      end

      -- add rule to the grammar
      -- adverbial rule
      if next(adverbs) ~= nil then

        if adverbs["quantifier"] == "+" or adverbs["quantifier"] == "*" then

          -- todo: separator = [ 'discard' [ 'keep' ] ] adverb,
          --    'discard' being the default value

          -- add separator symbol
          local S_separator = g:symbol_new(adverbs["separator"])
          -- add item symbol
          assert( #rhs_alternative == 1, "sequence rule must have only 1 symbol on its RHS" )
          local S_item = g:symbol_new(rhs_alternative[1])
          -- add sequence rule
          g:sequence_new (
              S_lhs, S_item, S_separator, adverbs["quantifier"],
              marpa.PROPER_SEPARATION
            )
        else
          -- other rule types based on adverbs
          -- ...
        end
      -- adverbless rule
      else
        -- add rule's rhs symbols to the grammar
        local S_rhs_symbol = {}
        for ix, rhs_symbol in pairs(rhs_alternative) do
          S_rhs_symbol[ix] = g:symbol_new(rhs_symbol)
        end
        -- add adverbless rule
        g:rule_new(S_lhs, S_rhs_symbol)
      end
    end
  end
end
-- d.pt(d.i(token_spec))

-- todo: sanity check: all parser's terminals must exist as lexer rule's token_symbol's

-- todo: build a lexical grammar

-- lexer rules -- add terminal symbols to grammar
local token_spec = {}
assert( type(jg["lexer"]) == "table", [[Grammar spec must have a table under "lexer" key]])
for _, rule in ipairs(jg["lexer"]) do
    -- d.pt("# lexer rule")
    local token_pattern = rule[1]
    local token_symbol  = rule[2]
    -- token lhs must exist in the grammar after adding parser rules
    local S_token = g.symbols[token_symbol] or -1
    -- add to token_spec
    table.insert( token_spec, { token_pattern, token_symbol, S_token } )
end

-- d.pt(d.i(token_spec))

g:precompute()

ok (g:is_precomputed() >= 0, "json grammar precomputed")

local r = marpa.recognizer.new(g)

r:start_input()

--
-- read input from file, if specified on the command line, or set to default value
--

local input = ''
if table.getn(arg) > 0 then
  local f = io.open( arg[1], "r")
  if f ~= nil then
    input = f:read("*a")
    io.close(f)
  end
end
if input == '' then
  input = '[1,"abc\ndef",-2.3,null,[],[1,2,3],{},{"a":1,"b":2}]'
end

--
-- recognition
--

-- todo: expected_terminals must be recognizer method

-- lexer creation
local function expected_terminals(r)
  -- until kollos has _terminals_expected, return all terminals
  return {
    WHITESPACE = 1, NEWLINE = 1, MISMATCH = 1,
    lcurly = 1, rcurly = 1, lsquare = 1, rsquare = 1, comma = 1, colon = 1,
    string = 1, number = 1,
    ["true"] = 1, ["false"] = 1, null = 1
  }
end

require 'lexer'
local lex = lexer.new{tokens = token_spec, input = input, patterns = 'lua' }
local token_values = {}

-- todo: the below lexeme reading loop must go to recognizer's read(input, lexer) method
-- return terminals expected at current earleme
while true do

  local et = expected_terminals(r)
  local token_symbol, token_symbol_id, token_start, token_length, line, column = lex(et)
  if token_symbol == nil then break end

  if token_symbol == 'MISMATCH' then
    print(string.format("Invalid symbol '%s' at %d:%d", input:sub(token_start, token_length - 1), line, column ));
  elseif token_symbol_id >= 0 then
    local status = r:alternative ( token_symbol_id, token_start, 1 )
    if (not status) then
      error( 'result of alternative = ' .. status)
      break
    end
    status = r:earleme_complete()
    if (status < 0) then
      error("result of earleme_complete = " .. status)
    end
    token_values[token_start .. ""] = token_length
  end
end -- lexeme reading loop

--
-- valuation
--

local v = marpa.valuator.new(r)

-- todo: valuator must have value() iterator to use in for, like Marpa::R2

-- todo: the valuation loop must go to walk(value) valuator method
--       does the valuation loop walk the parse tree nodes (in pre-order?) building the AST/ASF

local stack = {}
local got_json = ''
-- stepping
local column = 0
while true do
  local step_type = v:step (v.value)
  if step_type == marpa.STEP_INACTIVE then
    -- print( "The valuator has gone through all of its steps" )
    break
  elseif step_type == marpa.STEP_RULE then
    local first_child_ix = v.value.t_arg_0
    local last_child_ix  = v.value.t_arg_n
    local rule_value_ix  = v.value.t_result -- rule value must go to that ix
    local rule_id = v.value.t_rule_id
    local rule_lhs_id = g:marpa_g_rule_lhs(rule_id)
--    io.stderr:write( sf( "R%-2d: %-10s stack[%2d:%2d] -> [%d]", rule_id, symbols[tostring(rule_lhs_id)], first_child_ix, last_child_ix, rule_value_ix ), "\n" )
  elseif step_type == marpa.STEP_TOKEN then

    local token_id = v.value.t_token_id
    -- we called _alternative with token_start as the value,
    -- hence the value is the start position of the token
    local token_value = v.value.t_token_value
    local token_value_ix = v.value.t_result
--    io.stderr:write( sf( "T%-2d: %-10s %d -> stack[%d]", token_id, symbols[tostring(token_id)], token_value, token_value_ix), "\n")

    local token_start = token_value
    local token_end = token_start + token_values[token_start .. ""] - 1
    local token = input:sub(token_start, token_end)
    -- got_json = got_json .. token
    column = column + string.len(token)
    if column > 60 then column = 0 got_json = got_json .. "\n" end
    got_json = got_json .. token

  end
end

-- test if we echoed the input

-- whitespaces are discarded in parsing,
-- so we remove them from the input
local expected_json = string.gsub(input, ' ', '')
is ( got_json, expected_json, 'json' )

done_testing()
