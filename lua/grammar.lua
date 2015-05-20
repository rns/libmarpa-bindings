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

  start_symbol = C.marpa_g_start_symbol,
  start_symbol_set = C.marpa_g_start_symbol_set,

  highest_symbol_id = C.marpa_g_highest_symbol_id,
  symbol_is_accessible = C.marpa_g_symbol_is_accessible,
  symbol_is_completion_event = C.marpa_g_symbol_is_completion_event,
  symbol_is_completion_event_set = C.marpa_g_symbol_is_completion_event_set,
  symbol_is_nulled_event = C.marpa_g_symbol_is_nulled_event,
  symbol_is_nulled_event_set = C.marpa_g_symbol_is_nulled_event_set,
  symbol_is_nullable = C.marpa_g_symbol_is_nullable,
  symbol_is_nulling = C.marpa_g_symbol_is_nulling,
  symbol_is_productive = C.marpa_g_symbol_is_productive,
  symbol_is_prediction_event = C.marpa_g_symbol_is_prediction_event,
  symbol_is_prediction_event_set = C.marpa_g_symbol_is_prediction_event_set,
  symbol_is_start = C.marpa_g_symbol_is_start,
  symbol_is_terminal = C.marpa_g_symbol_is_terminal,
  symbol_is_terminal_set = C.marpa_g_symbol_is_terminal_set,
  symbol_new = C.marpa_g_symbol_new,

  highest_rule_id = C.marpa_g_highest_rule_id,
  rule_is_accessible = C.marpa_g_rule_is_accessible,
  rule_is_nullable = C.marpa_g_rule_is_nullable,
  rule_is_nulling = C.marpa_g_rule_is_nulling,
  rule_is_loop = C.marpa_g_rule_is_loop,
  rule_is_productive = C.marpa_g_rule_is_productive,
  rule_length = C.marpa_g_rule_length,
  rule_new = C.marpa_g_rule_new,
  rule_lhs = C.marpa_g_rule_lhs,
  rule_rhs = C.marpa_g_rule_rhs,

  rule_is_proper_separation = C.marpa_g_rule_is_proper_separation,
  sequence_min = C.marpa_g_sequence_min,
  sequence_new = C.marpa_g_sequence_new,
  sequence_separator = C.marpa_g_sequence_separator,
  symbol_is_counted = C.marpa_g_symbol_is_counted,

  rule_rank = C.marpa_g_rule_rank,
  rule_rank_set = C.marpa_g_rule_rank_set,
  rule_null_high = C.marpa_g_rule_null_high,
  rule_null_high_set = C.marpa_g_rule_null_high_set,

  precompute = C.marpa_g_precompute,
  is_precomputed = C.marpa_g_is_precomputed,

  has_cycle = C.marpa_g_has_cycle,

  default_rank = C.marpa_g_default_rank,
  default_rank_set = C.marpa_g_default_rank_set,
  symbol_rank = C.marpa_g_symbol_rank,
  symbol_rank_set = C.marpa_g_symbol_rank_set,
  symbol_is_valued = C.marpa_g_symbol_is_valued,
  symbol_is_valued_set = C.marpa_g_symbol_is_valued_set,

}

function grammar_class.new()

  -- Marpa configurarion
  local config = ffi.new("Marpa_Config")
  C.marpa_c_init(config) -- always succeeds

  -- Marpa grammar
  local g = ffi.gc(C.marpa_g_new(config), C.marpa_g_unref)
  local rc = C.marpa_c_error(config, ffi.NULL)
  assert( rc == C.MARPA_ERR_NONE, "grammar creation failed, error code " .. rc)

  local grammar_object = { g = g }

  setmetatable( grammar_object, { __index =
    function (grammar_object, method)
      -- p("grammar wrapper for ", method)
      return function (grammar_object, ...)

        local c_function = grammar_class[method]
        assert (c_function ~= nil, "No such method: " .. method)

        local result

        if method == 'rule_new' then

          local args = {...}
          local lhs = table.remove(args, 1)
          args = args[1]
          assert( type(args) == 'table', "arg 2 to rule_new must be a table of RHS symbols")

          local rhs = ffi.new("int[" .. #args .. "]")
          for ix, symbol in ipairs(args) do
            -- p(i(symbol))
            rhs[ix-1] = symbol
          end

          result = c_function(grammar_object.g, lhs, rhs, #args)

        else
          -- p("calling", method)
          result = c_function(grammar_object.g, ...)
        end
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
