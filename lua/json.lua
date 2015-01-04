require 'os'

require 'libmarpa'
require 'libmarpa_codes'

local lib = libmarpa.lib
local ffi = libmarpa.ffi
local codes = libmarpa_codes

-- print version info
print(
  "os:",
  table.concat( { ffi.os, ffi.arch, ffi.abi('win') and "Windows variant" or "" }, '/' )
)

local ver = ffi.new("int [3]")
lib.marpa_version(ver)
print(string.format("libmarpa version: %1d.%1d.%1d", ver[0], ver[1], ver[2]))

print("LuaJIT version:", jit.version )

-- error handling
local function error_msg(func, g)
  local error_string = ffi.new("const char**")
  local error_code = lib.marpa_g_error(g, error_string)
  return string.format("%s returned %d: %s", func, error_code, error_string )
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

-- grammar symbols from RFC 7159
local S_begin_array = lib.marpa_g_symbol_new (g)
assert_result(S_begin_array, "marpa_g_symbol_new", g)
local S_begin_object = lib.marpa_g_symbol_new (g)
assert_result( S_begin_object, "marpa_g_symbol_new", g )
local S_end_array = lib.marpa_g_symbol_new (g)
assert_result( S_end_array, "marpa_g_symbol_new", g )
local S_end_object = lib.marpa_g_symbol_new (g)
assert_result( S_end_object, "marpa_g_symbol_new", g )
local S_name_separator = lib.marpa_g_symbol_new (g)
assert_result( S_name_separator, "marpa_g_symbol_new", g )
local S_value_separator = lib.marpa_g_symbol_new (g)
assert_result( S_value_separator, "marpa_g_symbol_new", g )
local S_member = lib.marpa_g_symbol_new (g)
assert_result( S_member, "marpa_g_symbol_new", g )
local S_value = lib.marpa_g_symbol_new (g)
assert_result( S_value, "marpa_g_symbol_new", g )
local S_false = lib.marpa_g_symbol_new (g)
assert_result( S_false, "marpa_g_symbol_new", g )
local S_null = lib.marpa_g_symbol_new (g)
assert_result( S_null, "marpa_g_symbol_new", g )
local S_true = lib.marpa_g_symbol_new (g)
assert_result( S_true, "marpa_g_symbol_new", g )
local S_object = lib.marpa_g_symbol_new (g)
assert_result( S_object, "marpa_g_symbol_new", g )
local S_array = lib.marpa_g_symbol_new (g)
assert_result( S_array, "marpa_g_symbol_new", g )
local S_number = lib.marpa_g_symbol_new (g)
assert_result( S_number, "marpa_g_symbol_new", g )
local S_string = lib.marpa_g_symbol_new (g)
assert_result( S_string, "marpa_g_symbol_new", g )

-- additional symbols
local S_object_contents = lib.marpa_g_symbol_new (g)
assert_result( S_object_contents, "marpa_g_symbol_new", g )
local S_array_contents = lib.marpa_g_symbol_new (g)
assert_result( S_array_contents, "marpa_g_symbol_new", g )

-- rules
local rhs = ffi.new("int[4]")

rhs[0] = S_false;
assert_result( lib.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_null;
assert_result( lib.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_true;
assert_result( lib.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_object;
assert_result( lib.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_array;
assert_result( lib.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_number;
assert_result( lib.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_string;
assert_result( lib.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )

rhs[0] = S_begin_array
rhs[1] = S_array_contents
rhs[2] = S_end_array
assert_result( lib.marpa_g_rule_new (g, S_array, rhs, 3), "marpa_g_rule_new", g )

rhs[0] = S_begin_object
rhs[1] = S_object_contents
rhs[2] = S_end_object
assert_result( lib.marpa_g_rule_new (g, S_object, rhs, 3), "marpa_g_rule_new", g )

assert_result(
  lib.marpa_g_sequence_new (
    g, S_array_contents, S_value, S_value_separator, 0, lib.MARPA_PROPER_SEPARATION
  ), "marpa_g_sequence_new", g
)

assert_result(
  lib.marpa_g_sequence_new (
    g, S_object_contents, S_member, S_value_separator, 0, lib.MARPA_PROPER_SEPARATION
  ), "marpa_g_sequence_new", g
)

rhs[0] = S_string;
rhs[1] = S_name_separator;
rhs[2] = S_value;
assert_result( lib.marpa_g_rule_new (g, S_member, rhs, 3), "marpa_g_rule_new", g )

assert_result( lib.marpa_g_start_symbol_set(g, S_value), "marpa_g_start_symbol_set", g )

assert_result( lib.marpa_g_precompute(g), "marpa_g_precompute", g )

local r = ffi.gc( lib.marpa_r_new(g), lib.marpa_r_unref )
assert_result( r, "marpa_g_precompute", g )

assert_result( lib.marpa_r_start_input(r), "marpa_r_start_input", g )

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

  assert( token_symbol ~= 'MISMATCH', string.format("Invalid token: <%s>", match ) )

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

-- steps
column = 0
while true do
  local step_type = lib.marpa_v_step (value)
  assert_result( step_type, "marpa_v_step", g )
  if step_type == lib.MARPA_STEP_INACTIVE then
    if false then print ("No more events\n") end
    break
  elseif step_type == lib.MARPA_STEP_TOKEN then
    local token = value.t_token_id
    if column > 60 then
      io.write ("\n")
      column = 0
    elseif token == S_begin_array then
      io.write ('[')
      column = column + 1
    elseif token == S_end_array then
      io.write (']')
      column = column + 1
    elseif token == S_begin_object then
      io.write ('{')
      column = column + 1
    elseif token == S_end_object then
      io.write ('}')
      column = column + 1
    elseif token == S_name_separator then
      io.write (':')
      column = column + 1
    elseif token == S_value_separator then
      io.write (',')
      column = column + 1
    elseif token == S_null then
      io.write( "null" )
      column = column + 4
    elseif token == S_true then
      io.write ('true')
      column = column + 1
    elseif token == S_false then
      io.write ('false')
      column = column + 1
    elseif token == S_number then
      local start_of_number = value.t_token_value
      io.write( token_values[start_of_number] )
      column = column + 1
    elseif token == S_string then
      local start_of_string = value.t_token_value
      io.write( token_values[start_of_string] )
    end
  end
end

io.write("\n")

