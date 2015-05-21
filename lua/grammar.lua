-- libmarpa binding
local lib   = require 'libmarpa'
local C     = lib.C
local ffi   = lib.ffi

--- debug helpers
local inspect = require 'inspect'
local i = inspect
local p = print

-- marpa_g_* methods
local grammar_class = {

  force_valued = C.marpa_g_force_valued,

  _start_symbol = C.marpa_g_start_symbol,
  _start_symbol_set = C.marpa_g_start_symbol_set,

  _highest_symbol_id = C.marpa_g_highest_symbol_id,
  _symbol_is_accessible = C.marpa_g_symbol_is_accessible,
  _symbol_is_completion_event = C.marpa_g_symbol_is_completion_event,
  _symbol_is_completion_event_set = C.marpa_g_symbol_is_completion_event_set,
  _symbol_is_nulled_event = C.marpa_g_symbol_is_nulled_event,
  _symbol_is_nulled_event_set = C.marpa_g_symbol_is_nulled_event_set,
  _symbol_is_nullable = C.marpa_g_symbol_is_nullable,
  _symbol_is_nulling = C.marpa_g_symbol_is_nulling,
  _symbol_is_productive = C.marpa_g_symbol_is_productive,
  _symbol_is_prediction_event = C.marpa_g_symbol_is_prediction_event,
  _symbol_is_prediction_event_set = C.marpa_g_symbol_is_prediction_event_set,
  _symbol_is_start = C.marpa_g_symbol_is_start,
  _symbol_is_terminal = C.marpa_g_symbol_is_terminal,
  _symbol_is_terminal_set = C.marpa_g_symbol_is_terminal_set,

  _highest_rule_id = C.marpa_g_highest_rule_id,
  _rule_is_accessible = C.marpa_g_rule_is_accessible,
  _rule_is_nullable = C.marpa_g_rule_is_nullable,
  _rule_is_nulling = C.marpa_g_rule_is_nulling,
  _rule_is_loop = C.marpa_g_rule_is_loop,
  _rule_is_productive = C.marpa_g_rule_is_productive,
  _rule_length = C.marpa_g_rule_length,
  _rule_lhs = C.marpa_g_rule_lhs,
  _rule_rhs = C.marpa_g_rule_rhs,

  _rule_is_proper_separation = C.marpa_g_rule_is_proper_separation,
  _sequence_min = C.marpa_g_sequence_min,
  _sequence_new = C.marpa_g_sequence_new,
  _sequence_separator = C.marpa_g_sequence_separator,
  _symbol_is_counted = C.marpa_g_symbol_is_counted,

  _rule_rank = C.marpa_g_rule_rank,
  _rule_rank_set = C.marpa_g_rule_rank_set,
  _rule_null_high = C.marpa_g_rule_null_high,
  _rule_null_high_set = C.marpa_g_rule_null_high_set,

  _precompute = C.marpa_g_precompute,
  _is_precomputed = C.marpa_g_is_precomputed,

  _has_cycle = C.marpa_g_has_cycle,

  _default_rank = C.marpa_g_default_rank,
  _default_rank_set = C.marpa_g_default_rank_set,
  _symbol_rank = C.marpa_g_symbol_rank,
  _symbol_rank_set = C.marpa_g_symbol_rank_set,
  _symbol_is_valued = C.marpa_g_symbol_is_valued,
  _symbol_is_valued_set = C.marpa_g_symbol_is_valued_set,

}

-- check if symbol s_str exists in the symbol table
-- call libmarpa method to add the symbol to the grammar if it doesn't
-- throw exception on error
-- return symbol id for s_str on success
function grammar_class.symbol_new(grammar_object, s_str)

  assert(type(s_str) == "string", "symbol must be a string")

  symbols = grammar_object.symbols

  local s_id = symbols[s_str]
  if s_id == nil then
    s_id = C.marpa_g_symbol_new(grammar_object.g)
    lib.assert (s_id, "marpa_g_symbol_new", grammar_object.g)
    symbols[tostring(s_id)] = s_str
    symbols[s_str]    = s_id
  else
    s_id = symbols[s_str]
  end

  return s_id
end

-- create a C array of rhs symbol id’s from Lua table of RHS_IDs
-- call libmarpa method, throw exception on error
-- return new rule id on success
function grammar_class.rule_new(grammar_object, lhs_id, RHS_IDs)

  assert( type(RHS_IDs) == 'table', "arg 2 to rule_new must be a table of RHS symbols")

  local rhs_ids = ffi.new("int[" .. #RHS_IDs .. "]")
  for ix, symbol in ipairs(RHS_IDs) do
    -- p(i(symbol))
    rhs_ids[ix-1] = symbol
  end

  result = C.marpa_g_rule_new(grammar_object.g, lhs_id, rhs_ids, #RHS_IDs)
  lib.assert (result, "marpa_g_rule_new", grammar_object.g)
  return result

end

function grammar_class.new()

  -- Marpa configurarion
  local config = ffi.new("Marpa_Config")
  C.marpa_c_init(config) -- always succeeds

  -- Marpa grammar
  local g = ffi.gc(C.marpa_g_new(config), C.marpa_g_unref)
  local rc = C.marpa_c_error(config, ffi.NULL)
  assert( rc == C.MARPA_ERR_NONE, "grammar creation failed, error code " .. rc)

  local symbols = {} -- symbol table

  local grammar_object = { g = g, symbols = symbols }

  setmetatable( grammar_object, { __index =
    function (grammar_object, method)
      -- if class provides a wrapper, return it
      local class_method = grammar_class[method]
      if class_method ~= nil then
        return function (grammar_object, ...) return class_method(grammar_object, ...) end
      end
      -- otherwise return generic wrapper -- C function call + error checking
      return function (grammar_object, ...)
        -- get and call C function
        local c_function = grammar_class['_' .. method]
        assert (c_function ~= nil, "No C function for: " .. '_' .. method)
        local result = c_function(grammar_object.g, ...)
        -- throw exception on error
        lib.assert (result, "marpa_g_" .. method, grammar_object.g)
        -- return call result otherwise
        return result
      end
    end
  })

  return grammar_object

end

return grammar_class
