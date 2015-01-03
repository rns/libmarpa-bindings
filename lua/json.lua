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

-- utility funcs
function fail(s, g)
  local e = lib.marpa_g_error(g, ffi.new("const char**"))
  assert( e == lib.MARPA_ERR_NONE, s .. ': ' .. table.concat( codes.errors[e + 1], ': ' ) )
end

-- init Marpa
config = ffi.new("Marpa_Config")
lib.marpa_c_init(config)

g = ffi.gc(lib.marpa_g_new(config), lib.marpa_g_unref)
msg = ffi.new("const char **")
assert( lib.marpa_c_error(config, msg) == lib.MARPA_ERR_NONE, msg )

-- grammar symbols from RFC 7159
S_begin_array = lib.marpa_g_symbol_new (g)
assert( S_begin_array >= 0, fail ("marpa_g_symbol_new", g) )
S_begin_object = lib.marpa_g_symbol_new (g)
assert( S_begin_object >= 0, fail ("marpa_g_symbol_new", g) )
S_end_array = lib.marpa_g_symbol_new (g)
assert( S_end_array >= 0, fail ("marpa_g_symbol_new", g) )
S_end_object = lib.marpa_g_symbol_new (g)
assert( S_end_object >= 0, fail ("marpa_g_symbol_new", g) )
S_name_separator = lib.marpa_g_symbol_new (g)
assert( S_name_separator >= 0, fail ("marpa_g_symbol_new", g) )
S_value_separator = lib.marpa_g_symbol_new (g)
assert( S_value_separator >= 0, fail ("marpa_g_symbol_new", g) )
S_member = lib.marpa_g_symbol_new (g)
assert( S_member >= 0, fail ("marpa_g_symbol_new", g) )
S_value = lib.marpa_g_symbol_new (g)
assert( S_value >= 0, fail ("marpa_g_symbol_new", g) )
S_false = lib.marpa_g_symbol_new (g)
assert( S_false >= 0, fail ("marpa_g_symbol_new", g) )
S_null = lib.marpa_g_symbol_new (g)
assert( S_null >= 0, fail ("marpa_g_symbol_new", g) )
S_true = lib.marpa_g_symbol_new (g)
assert( S_true >= 0, fail ("marpa_g_symbol_new", g) )
S_object = lib.marpa_g_symbol_new (g)
assert( S_object >= 0, fail ("marpa_g_symbol_new", g) )
S_array = lib.marpa_g_symbol_new (g)
assert( S_array >= 0, fail ("marpa_g_symbol_new", g) )
S_number = lib.marpa_g_symbol_new (g)
assert( S_number >= 0, fail ("marpa_g_symbol_new", g) )
S_string = lib.marpa_g_symbol_new (g)
assert( S_string >= 0, fail ("marpa_g_symbol_new", g) )

-- additional symbols
S_object_contents = lib.marpa_g_symbol_new (g)
assert( S_object_contents >= 0, fail ("marpa_g_symbol_new", g) )
S_array_contents = lib.marpa_g_symbol_new (g)
assert( S_array_contents >= 0, fail ("marpa_g_symbol_new", g) )

-- rules
rhs = ffi.new("int[4]")
rhs[0] = S_false;
assert( lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g) )
rhs[0] = S_null;
assert( lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g) )
rhs[0] = S_true;
assert( lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g) )
rhs[0] = S_object;
assert( lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g) )
rhs[0] = S_array;
assert( lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g) )
rhs[0] = S_number;
assert( lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g) )
rhs[0] = S_string;
assert( lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g) )

rhs[0] = S_begin_array
rhs[1] = S_array_contents
rhs[2] = S_end_array
assert( lib.marpa_g_rule_new (g, S_array, rhs, 3) >= 0, fail ("marpa_g_rule_new", g) )

rhs[0] = S_begin_object
rhs[1] = S_object_contents
rhs[2] = S_end_object
assert( lib.marpa_g_rule_new (g, S_object, rhs, 3) >= 0, fail ("marpa_g_rule_new", g) )

assert(
  lib.marpa_g_sequence_new (
    g, S_array_contents, S_value, S_value_separator, 0, lib.MARPA_PROPER_SEPARATION
  ) >= 0,
  fail ("marpa_g_sequence_new", g) )
assert(
  lib.marpa_g_sequence_new (
    g, S_object_contents, S_member, S_value_separator, 0, lib.MARPA_PROPER_SEPARATION
  ) >= 0,
  fail ("marpa_g_sequence_new", g) )

rhs[0] = S_string;
rhs[1] = S_name_separator;
rhs[2] = S_value;
assert( lib.marpa_g_rule_new (g, S_member, rhs, 3) >= 0, fail ("marpa_g_rule_new", g) )

assert( lib.marpa_g_start_symbol_set (g, S_value) >= 0, fail ("marpa_g_start_symbol_set", g) )

if lib.marpa_g_precompute (g) < 0 then
  fail ("marpa_g_precompute", g)
  os.exit (1)
end

r = lib.marpa_r_new (g)

if r == ffi.NULL then
  fail ("marpa_g_precompute", g)
  os.exit (1)
end

if not (lib.marpa_r_start_input (r) >= 0) then
  fail ("marpa_g_precompute", g)
  os.exit (1)
end

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

local line = 1
local column = 1

local token_values = {}
local token_start = 1
local token_length

while true do

  local pattern
  local token_symbol
  local token_id
  local match

  for i, triple in ipairs(token_spec) do

    pattern         = triple[1]
    token_symbol    = triple[2]
    token_symbol_id = triple[3]

    match = string.match(input, "^" .. pattern)
    if match ~= nil then
      input = string.gsub(input, "^" .. pattern, "")
      break
    end

  end

  if token_symbol == 'NEWLINE' then
    column = 1
    line = line + 1
    token_start = token_start + 1
  elseif token_symbol == 'SKIP' then
    column = column + string.len(match)
    token_start = token_start + string.len(match)
  elseif token_symbol == 'MISMATCH' then
    print("Invalid token:", match)
    os.exit(1)
    break
  else
--    print (token_symbol, token_symbol_id, match, '@', token_start, ';', line, ':', column)
    column = column + string.len(match)
    token_start = token_start + string.len(match)
    token_value = match

    status = lib.marpa_r_alternative (r, token_symbol_id, token_start, 1)
    if status ~= lib.MARPA_ERR_NONE then
      expected = ffi.new("Marpa_Symbol_ID*")
      count_of_expected = lib.marpa_r_terminals_expected (r, expected)
      -- todo: list expected terminals
      print( 'marpa_r_alternative: ' + table.concat( codes.errors[status], ', ') )
      os.exit (1)
    end

    status = lib.marpa_r_earleme_complete (r)
    if status < 0 then
      e = lib.marpa_g_error (g, ffi.new("const char**"))
      print ('marpa_r_earleme_complete:' + e)
      os.exit (1)
    end

    token_values[token_start] = token_value
  end
  if input == '' then break end
end

-- for k, v in pairs(token_values) do print (k, v) end

local bocage = lib.marpa_b_new (r, -1)
if bocage == ffi.NULL then
  e = lib.marpa_g_error (g, ffi.new("const char**"))
  print("bocage:", table.concat( codes.errors[e + 1], ': ' ))
  os.exit (1)
end

local order = lib.marpa_o_new (bocage)
if order == ffi.NULL then
  local e = lib.marpa_g_error (g, ffi.new("const char**"))
  print("order:", table.concat( codes.errors[e + 1], ': ' ))
  os.exit (1)
end

local tree = lib.marpa_t_new (order)
if tree == ffi.NULL then
  local e = lib.marpa_g_error (g, ffi.new("const char**"))
  print("tree:", table.concat( codes.errors[e + 1], ': ' ))
  os.exit (1)
end

local value = ffi.NULL
local tree_status = lib.marpa_t_next (tree)
if tree_status <= -1 then
  local e = lib.marpa_g_error (g, ffi.new("const char**"))
  print("marpa_t_next returned:", e, table.concat( codes.errors[e + 1], ': ' ))
  os.exit (1)
end

local value = lib.marpa_v_new (tree)
if value == ffi.NULL then
  local e = lib.marpa_g_error (g, ffi.new("const char**"))
  print("marpa_v_new returned:", e, table.concat( codes.errors[e + 1], ': ' ))
  os.exit (1)
end

column = 0

while true do
  step_type = lib.marpa_v_step (value)
  if step_type < 0 then
    e = lib.marpa_g_error (g, ffi.new("const char**"))
    print("marpa_v_event returned:", e, table.concat( codes.errors[e + 1], ': ' ))
    os.exit (1)
  elseif step_type == lib.MARPA_STEP_INACTIVE then
    if false then print ("No more events\n") end
    break
  elseif step_type == lib.MARPA_STEP_TOKEN then
    token = value.t_token_id
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
      start_of_number = value.t_token_value
      io.write( token_values[start_of_number] )
      column = column + 1
    elseif token == S_string then
      start_of_string = value.t_token_value
      io.write( token_values[start_of_string] )
    end
  end
end

io.write("\n")

