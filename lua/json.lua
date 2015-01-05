require 'os'

local d = require 'printf_debugging'

-- libmarpa binding
require 'libmarpa'
require 'libmarpa_codes'

local lib = libmarpa.lib
local ffi = libmarpa.ffi
local codes = libmarpa_codes

-- print platform versions
d.p(
  "os:",
  table.concat( { ffi.os, ffi.arch, ffi.abi('win') and "Windows variant" or "" }, '/' )
)

local ver = ffi.new("int [3]")
lib.marpa_version(ver)
d.p(d.sf("libmarpa version: %1d.%1d.%1d", ver[0], ver[1], ver[2]))

d.p("LuaJIT version:", jit.version )
d.p(string.rep('-', 28))

-- error handling
local function error_msg(func, g)
  local error_string = ffi.new("const char**")
  local error_code = lib.marpa_g_error(g, error_string)
  return d.sf("%s returned %d: %s", func, error_code, error_string )
end

local function assert_result(result, func, g)
  local type = type(result)
  lib.marpa_g_error_clear(g)
  if type == "number" then
    assert( result >= 0, error_msg(func, g) )
  elseif type == "cdata" then
    assert( result ~= ffi.NULL, error_msg(func, g) )
  end
end

-- Marpa configurarion
local config = ffi.new("Marpa_Config")
lib.marpa_c_init(config) -- always succeeds

-- grammar
local g = ffi.gc(lib.marpa_g_new(config), lib.marpa_g_unref)
local msg = ffi.new("const char **")
assert( lib.marpa_c_error(config, msg) == lib.MARPA_ERR_NONE, msg )

--[[ this is arguably not for "racing car" programs as efficiency can
  potentially be gained by not-caring about values of some symbols
  e.g. array/objects' begin's/end's, separators, etc. ]]--
assert_result( lib.marpa_g_force_valued(g), "marpa_g_force_valued", g )

-- JSON grammar specification
-- only symbols in quotes: no literals or regexes
--[[
  lhs = 'rhs' -- lexical rules, rhs can be a string or a Lua pattern or (in future) a regex
  lhs = {
    { 'rhs1', ... }
    { 'rhs2', ... { adverb = value, ... } }
  }
]]--
local jg = {
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

  -- lexer rules
  lcurly  = '{',
  rcurly  = '}',
  lsquare = '[',
  rsquare = ']',
  comma   = ',',
  colon   = ':',

  string  = '"[^"]+"',
  number  = '-?[%d]+[.%d+]*',

  ["true"]  = 'true',  -- true is a keyword in Lua
  ["false"] = 'false', -- and so is false
  null      = 'null',

}

local symbols = {} -- symbol table
-- add symbol s to grammar g avoiding duplication via symbols table
-- if symbol exists, return its id
local function symbol_new(s, g)
  assert(type(s) == "string", "symbol must be a string")
  assert(type(g) == "cdata", "grammar must be cdata")
  local s_id = symbols[s]
  if s_id == nil then
    s_id = lib.marpa_g_symbol_new (g)
    assert_result(s_id, "marpa_g_symbol_new", g)
    symbols[tostring(s_id)] = s
    symbols[s]    = s_id
  else
    s_id = symbols[s]
  end
  return s_id
end

for lhs, rhs in pairs(jg) do
  d.pt(lhs, ':=', d.s(rhs))
  -- handle start symbol
  if lhs == '_start_symbol' then
    local S_start = symbol_new(rhs, g)
    assert_result( lib.marpa_g_start_symbol_set(g, S_start), "marpa_g_start_symbol_set", g )
  else
    -- add lhs symbol to the grammar
    local S_lhs = symbol_new(lhs, g)
    -- add rhs symbol to grammar
    local rhs_type = type(rhs)
    if rhs_type == "table" then
      -- parser rule
      for _, rhs_alternative in ipairs(rhs) do
        -- extract rule's adverbs, if any
        local adverbs = {}
        if type(rhs_alternative[#rhs_alternative]) == "table" then
          adverbs = table.remove(rhs_alternative)
        end
        -- add rule's rhs symbols to the grammar
        local S_rhs_symbol = {}
        for ix, rhs_symbol in pairs(rhs_alternative) do
          S_rhs_symbol[ix] = symbol_new(rhs_symbol, g)
        end
        -- add rule to the grammar
        d.pt(lhs, ':=', d.s(rhs_alternative))
        if next(adverbs) ~= nil then
          -- based on adverbs
          if adverbs["quantifier"] == "+" or adverbs["quantifier"] == "*" then
            d.pt("# sequence rule")
            d.pt(d.i(adverbs))
            -- todo implement keep (separator) adverb, off by default
            -- add separator symbol
            local S_separator = symbol_new(adverbs["separator"], g)
            -- add item symbol
            assert( #rhs_alternative == 1, "sequence rule must have only 1 symbol on its RHS" )
            local S_item = S_rhs_symbol[1]
            d.pt(d.i(S_separator, S_item))
            assert_result(
              lib.marpa_g_sequence_new (
                g, S_lhs, S_item, S_separator,
                adverbs["quantifier"] == "+" and 1 or 0,
                lib.MARPA_PROPER_SEPARATION
              ), "marpa_g_sequence_new", g
            )
          else
            -- other rule types based on adverbs
            -- ...
          end
        else -- normal rule
          d.pt("# normal rule")
          local rhs = ffi.new("int[" .. #rhs_alternative .. "]")
          for ix = 1, #rhs_alternative do
            rhs[ix-1] = S_rhs_symbol[ix]
          end
          assert_result( lib.marpa_g_rule_new (g, S_lhs, rhs, #rhs_alternative), "marpa_g_rule_new", g )
        end
      end
    elseif rhs_type == "string" then
      -- lexer rule
      d.pt("# lexer rule")
      -- add to token_spec
    end
  end
end
d.pt(d.i(symbols))

assert_result( lib.marpa_g_precompute(g), "marpa_g_precompute", g )

local r = ffi.gc( lib.marpa_r_new(g), lib.marpa_r_unref )
assert_result( r, "marpa_r_new", g )

assert_result( lib.marpa_r_start_input(r), "marpa_r_start_input", g )

os.exit()

-- read input from file, if specified on the command line, or set to default value
local input = ''
if table.getn(arg) > 0 then
  local f = io.open( arg[1], "r")
  if f ~= nil then
    input = f:read("*a")
    io.close(f)
  end
end
if input == '' then
  input = '[ 1, "abc\ndef", -2.3, null, [], true, false, [1,2,3], {}, {"a":1,"b":2} ]'
end

print( input )

-- lexing
local S_none = -1
local token_spec = {
  {'{',   'S_begin_object',     S_begin_object},
  {'}',   'S_end_object',       S_end_object},
  {'%[',  'S_begin_array',      S_begin_array}, -- % is escape char
  {'%]',  'S_end_array',        S_end_array},
  {',',   'S_value_separator',  S_value_separator},
  {':',   'S_name_separator',   S_name_separator},

  {'"[^"]+"',         'S_string', S_string},  -- todo: stricter string and number
  {'-?[%d]+[.%d+]*',  'S_number', S_number},  -- regexes

  {'true',  'S_true',   S_true},
  {'false', 'S_false',  S_false},
  {'null',  'S_null',   S_null},

  {'[ \t]+',  'SKIP',     S_none},  -- Skip over spaces and tabs
  {"\n",      'NEWLINE',  S_none},  -- Line endings
  {'.',       'MISMATCH', S_none},  -- Any other character
}

local line   = 1
local column = 1

local token_value  = ''
local token_values = {}
local token_start  = 1
local token_length = 0

while true do

  local pattern
  local token_symbol
  local token_symbol_id
  local match

  for _, triple in ipairs(token_spec) do

    pattern         = triple[1]
    token_symbol    = triple[2]
    token_symbol_id = triple[3]

    match = string.match(input, "^" .. pattern)
    if match ~= nil then
      input = string.gsub(input, "^" .. pattern, "")
      break
    end

  end

  assert( token_symbol ~= 'MISMATCH', sf("Invalid token: <%s>", match ) )

  if token_symbol == 'NEWLINE' then
    column = 1
    line = line + 1
    token_start = token_start + 1
  elseif token_symbol == 'SKIP' then
    column = column + string.len(match)
    token_start = token_start + string.len(match)
  else
--    print (token_symbol, token_symbol_id, match, '@', token_start, ';', line, ':', column)
    token_length = string.len(match)
    column = column + token_length
    token_start = token_start + token_length
    token_value = match

    local status = lib.marpa_r_alternative (r, token_symbol_id, token_start, 1)
    if status ~= lib.MARPA_ERR_NONE then
      local expected = ffi.new("Marpa_Symbol_ID*")
      local count_of_expected = lib.marpa_r_terminals_expected (r, expected)
      -- todo: list expected terminals
      assert_result( status, 'marpa_r_alternative', g )
    end

    status = lib.marpa_r_earleme_complete (r)
    assert_result( status, 'marpa_r_earleme_complete', g )

    -- save token value for evaluation
    -- todo: move tokenizing to start:len via string.find
    token_values[token_start] = token_value
  end
  if input == '' then break end
end

-- for k, v in pairs(token_values) do print (k, v) end

-- valuation
local bocage = ffi.gc( lib.marpa_b_new (r, -1), lib.marpa_b_unref )
assert_result( bocage, "marpa_b_new", g )

local order  = ffi.gc( lib.marpa_o_new (bocage), lib.marpa_o_unref )
assert_result( order, "marpa_o_new", g )

local tree   = ffi.gc( lib.marpa_t_new (order), lib.marpa_t_unref )
assert_result( tree, "marpa_t_new", g )

local tree_status = lib.marpa_t_next (tree)
assert_result( tree_status, "marpa_t_next", g )

local value = ffi.gc( lib.marpa_v_new (tree), marpa_v_unref )
assert_result( value, "marpa_v_new", g )

-- todo:
--  build the json tree
--  handle ambuguity

local stack = {}
-- steps
column = 0
while true do
  local step_type = lib.marpa_v_step (value)
  assert_result( step_type, "marpa_v_step", g )
  if step_type == lib.MARPA_STEP_INACTIVE then
    -- "The valuator has gone through all of its steps"
    break
  elseif step_type == lib.MARPA_STEP_RULE then
    local arg_0 = value.t_arg_0
    local arg_n = value.t_arg_n
    local rule_id = value.t_rule_id
    local arg_to = value.t_result
--    io.stderr:write( sf( "R %2d, stack[%2d:%2d] -> [%d]", rule_id, arg_0, arg_n, arg_to ), "\n" )
  elseif step_type == lib.MARPA_STEP_TOKEN then

    local token_id = value.t_token_id
    -- we called _alternative with token_start as the value,
    -- hence the value is the start position of the token
    local token_value = value.t_token_value
    local arg_to = value.t_result
--    io.stderr:write( sf( "T %2d, %d -> stack[%d]", token_id, token_value, arg_to), "\n")

    if column > 60 then
      io.write ("\n")
      column = 0
    elseif token_id == S_begin_array then
      io.write ('[')
      column = column + 1
    elseif token_id == S_end_array then
      io.write (']')
      column = column + 1
    elseif token_id == S_begin_object then
      io.write ('{')
      column = column + 1
    elseif token_id == S_end_object then
      io.write ('}')
      column = column + 1
    elseif token_id == S_name_separator then
      io.write (':')
      column = column + 1
    elseif token_id == S_value_separator then
      io.write (',')
      column = column + 1
    elseif token_id == S_null then
      io.write( "null" )
      column = column + 4
    elseif token_id == S_true then
      io.write ('true')
      column = column + 1
    elseif token_id == S_false then
      io.write ('false')
      column = column + 1
    elseif token_id == S_number then
      local start_of_number = token_value
      io.write( token_values[start_of_number] )
      column = column + 1
    elseif token_id == S_string then
      local start_of_string = token_value
      io.write( token_values[start_of_string] )
    end
  end
end

io.write("\n")

