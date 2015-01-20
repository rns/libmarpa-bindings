-- archetypal Libmarpa application: JSON Parser
require 'os'

package.path = '?.lua;../lua/?.lua;' .. package.path

-- libmarpa
local lib   = require 'libmarpa'
local C     = lib.C
local ffi   = lib.ffi

-- print platform versions
print(
  "os:",
  table.concat( { ffi.os, ffi.arch, ffi.abi('win') and "Windows variant" or "" }, '/' )
)

local ver = ffi.new("int [3]")
C.marpa_version(ver)
print(string.format("libmarpa version: %1d.%1d.%1d", ver[0], ver[1], ver[2]))

print("LuaJIT version:", jit.version )
print(string.rep('-', 28))

-- Marpa configurarion
local config = ffi.new("Marpa_Config")
C.marpa_c_init(config) -- always succeeds

-- grammar
local g = ffi.gc(C.marpa_g_new(config), C.marpa_g_unref)
local msg = ffi.new("const char **")
assert( C.marpa_c_error(config, msg) == C.MARPA_ERR_NONE, msg )

--[[ this is arguably not for "racing car" programs as efficiency can
  potentially be gained by not-caring about values of some symbols
  e.g. array/objects' begin's/end's, separators, etc. ]]--
lib.assert( C.marpa_g_force_valued(g), "marpa_g_force_valued", g )

-- grammar symbols from RFC 7159
local S_begin_array = C.marpa_g_symbol_new (g)
lib.assert(S_begin_array, "marpa_g_symbol_new", g)
local S_begin_object = C.marpa_g_symbol_new (g)
lib.assert( S_begin_object, "marpa_g_symbol_new", g )
local S_end_array = C.marpa_g_symbol_new (g)
lib.assert( S_end_array, "marpa_g_symbol_new", g )
local S_end_object = C.marpa_g_symbol_new (g)
lib.assert( S_end_object, "marpa_g_symbol_new", g )
local S_name_separator = C.marpa_g_symbol_new (g)
lib.assert( S_name_separator, "marpa_g_symbol_new", g )
local S_value_separator = C.marpa_g_symbol_new (g)
lib.assert( S_value_separator, "marpa_g_symbol_new", g )
local S_member = C.marpa_g_symbol_new (g)
lib.assert( S_member, "marpa_g_symbol_new", g )
local S_value = C.marpa_g_symbol_new (g)
lib.assert( S_value, "marpa_g_symbol_new", g )
local S_false = C.marpa_g_symbol_new (g)
lib.assert( S_false, "marpa_g_symbol_new", g )
local S_null = C.marpa_g_symbol_new (g)
lib.assert( S_null, "marpa_g_symbol_new", g )
local S_true = C.marpa_g_symbol_new (g)
lib.assert( S_true, "marpa_g_symbol_new", g )
local S_object = C.marpa_g_symbol_new (g)
lib.assert( S_object, "marpa_g_symbol_new", g )
local S_array = C.marpa_g_symbol_new (g)
lib.assert( S_array, "marpa_g_symbol_new", g )
local S_number = C.marpa_g_symbol_new (g)
lib.assert( S_number, "marpa_g_symbol_new", g )
local S_string = C.marpa_g_symbol_new (g)
lib.assert( S_string, "marpa_g_symbol_new", g )

-- additional symbols
local S_object_contents = C.marpa_g_symbol_new (g)
lib.assert( S_object_contents, "marpa_g_symbol_new", g )
local S_array_contents = C.marpa_g_symbol_new (g)
lib.assert( S_array_contents, "marpa_g_symbol_new", g )

--[[

S_value ::= S_false
S_value ::= S_null
S_value ::= S_true
S_value ::= S_object
S_value ::= S_array
S_value ::= S_number
S_value ::= S_string

S_array ::= S_begin_array S_array_contents S_end_array
S_object ::= S_begin_object S_object_contents S_end_object

S_array_contents ::= S_value*, S_value_separator, 0, C.MARPA_PROPER_SEPARATION
S_object_contents ::= S_member*, S_value_separator, 0, C.MARPA_PROPER_SEPARATION

S_member ::= S_string S_name_separator S_value

:start = S_value

]]--

-- rules
local rhs = ffi.new("int[4]")

rhs[0] = S_false;
lib.assert( C.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_null;
lib.assert( C.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_true;
lib.assert( C.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_object;
lib.assert( C.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_array;
lib.assert( C.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_number;
lib.assert( C.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )
rhs[0] = S_string;
lib.assert( C.marpa_g_rule_new (g, S_value, rhs, 1), "marpa_g_rule_new", g )

rhs[0] = S_begin_array
rhs[1] = S_array_contents
rhs[2] = S_end_array
lib.assert( C.marpa_g_rule_new (g, S_array, rhs, 3), "marpa_g_rule_new", g )

rhs[0] = S_begin_object
rhs[1] = S_object_contents
rhs[2] = S_end_object
lib.assert( C.marpa_g_rule_new (g, S_object, rhs, 3), "marpa_g_rule_new", g )

lib.assert(
  C.marpa_g_sequence_new (
    g, S_array_contents, S_value, S_value_separator, 0, C.MARPA_PROPER_SEPARATION
  ), "marpa_g_sequence_new", g
)

lib.assert(
  C.marpa_g_sequence_new (
    g, S_object_contents, S_member, S_value_separator, 0, C.MARPA_PROPER_SEPARATION
  ), "marpa_g_sequence_new", g
)

rhs[0] = S_string
rhs[1] = S_name_separator
rhs[2] = S_value
lib.assert( C.marpa_g_rule_new (g, S_member, rhs, 3), "marpa_g_rule_new", g )

lib.assert( C.marpa_g_start_symbol_set(g, S_value), "marpa_g_start_symbol_set", g )

lib.assert( C.marpa_g_precompute(g), "marpa_g_precompute", g )

local r = ffi.gc( C.marpa_r_new(g), C.marpa_r_unref )
lib.assert( r, "marpa_r_new", g )

lib.assert( C.marpa_r_start_input(r), "marpa_r_start_input", g )

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

-- lexing
local S_none = -1
local token_spec = {
  { [[\{]],   'S_begin_object',     S_begin_object},
  { [[\}]],   'S_end_object',       S_end_object},
  { [[\[]],  'S_begin_array',      S_begin_array},
  { '\\]',  'S_end_array',        S_end_array},
  { ',',   'S_value_separator',  S_value_separator},
  { ':',   'S_name_separator',   S_name_separator},

  { [["(?:(?:[^"\\]|\\[\\"/bfnrt]|\\u\d{4})*)"]], 'S_string', S_string},
  { [[-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?]],  'S_number', S_number},

  { [[\btrue\b]],  'S_true',   S_true},
  { [[\bfalse\b]], 'S_false',  S_false},
  { [[\bnull\b]],  'S_null',   S_null},

  {'[ \t]+',  'SKIP',     S_none},  -- Skip over spaces and tabs
  {"\n",      'NEWLINE',  S_none},  -- Line endings
  {'.',       'MISMATCH', S_none},  -- Any other character
}

require 'lexer'
local lex = lexer.new{tokens = token_spec, input = input }
local token_values = {}

while true do

  local expected_terminals = {} for _, v in pairs(token_spec) do expected_terminals[v[2]] = 1 end
  local token_symbol, token_symbol_id, token_start, token_length, line, column = lex(expected_terminals)
  if token_symbol == nil then break end

  if token_symbol == 'MISMATCH' then
    print(string.format("Invalid symbol '%s' at %d:%d", input:sub(token_start, token_start + token_length - 1), line, column ));
  elseif token_symbol_id >= 0 then
    local status = C.marpa_r_alternative (r, token_symbol_id, token_start, 1)
    if status ~= C.MARPA_ERR_NONE then
--      lib.assert( status, 'marpa_r_alternative', g )
      print("marpa_r_alternative returned error: ", status)
      os.exit(1)
    end
    status = C.marpa_r_earleme_complete (r)
    -- lib.assert( status, 'marpa_r_earleme_complete', g )
    if status == -2 then
      print("marpa_r_earleme_complete failed")
      os.exit(1)
    end
    token_values[tostring(token_start)] = input:sub(token_start, token_start + token_length - 1)
  end

end

-- for k, v in pairs(token_values) do print (k, v) end

-- valuation
local bocage = ffi.gc( C.marpa_b_new (r, -1), C.marpa_b_unref )
lib.assert( bocage, "marpa_b_new", g )

local order  = ffi.gc( C.marpa_o_new (bocage), C.marpa_o_unref )
lib.assert( order, "marpa_o_new", g )

local tree   = ffi.gc( C.marpa_t_new (order), C.marpa_t_unref )
lib.assert( tree, "marpa_t_new", g )

local tree_status = C.marpa_t_next (tree)
lib.assert( tree_status, "marpa_t_next", g )

local value = ffi.gc( C.marpa_v_new (tree), marpa_v_unref )
lib.assert( value, "marpa_v_new", g )

-- steps
column = 0
while true do
  local step_type = C.marpa_v_step (value)
  if step_type == C.MARPA_STEP_INACTIVE then
    if false then print ("No more events\n") end
    break
  elseif step_type == C.MARPA_STEP_TOKEN then
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
      local number = token_values[tostring(start_of_number)]
      io.write( number )
      column = column + string.len(number)
    elseif token == S_string then
      local start_of_string = value.t_token_value
      local string = token_values[tostring(start_of_string)]
      io.write( string )
      column = column + string.len(string)
    end
  end
end

io.write("\n")
