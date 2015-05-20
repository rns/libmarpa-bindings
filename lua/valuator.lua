-- libmarpa binding
local lib   = require 'libmarpa'
local C     = lib.C
local ffi   = lib.ffi

--- debug helpers
local inspect = require 'inspect'
local i = inspect
local p = print

-- marpa_v_* methods
local valuator_class = {

  b_new = C.marpa_b_new,
  b_ambiguity_metric = C.marpa_b_ambiguity_metric,
  b_is_null = C.marpa_b_is_null,

  o_new = C.marpa_o_new,
  o_ambiguity_metric = C.marpa_o_ambiguity_metric,
  o_is_null = C.marpa_o_is_null,
  o_high_rank_only_set = C.marpa_o_high_rank_only_set,
  o_high_rank_only = C.marpa_o_high_rank_only,
  o_rank = C.marpa_o_rank,

  t_new = C.marpa_t_new,
  t_ref = C.marpa_t_ref,
  t_next = C.marpa_t_next,
  t_parse_count = C.marpa_t_parse_count,

  v_new = C.marpa_v_new,
  v_step = C.marpa_v_step,

  v_symbol_is_valued = C.marpa_v_symbol_is_valued,
  v_symbol_is_valued_set = C.marpa_v_symbol_is_valued_set,
  v_rule_is_valued = C.marpa_v_rule_is_valued,
  v_rule_is_valued_set = C.marpa_v_rule_is_valued_set,
  v_valued_force = C.marpa_v_valued_force,

}

--[[ these need to be methods?

// #define marpa_v_step_type(v) ((v)->t_step_type)
// #define marpa_v_token(v) \
//    ((v)->t_token_id)
// #define marpa_v_symbol(v) marpa_v_token(v)
// #define marpa_v_token_value(v) \
//    ((v)->t_token_value)
// #define marpa_v_rule(v) \
//    ((v)->t_rule_id)
// #define marpa_v_arg_0(v) \
//    ((v)->t_arg_0)
// #define marpa_v_arg_n(v) \
//    ((v)->t_arg_n)
// #define marpa_v_result(v) \
//    ((v)->t_result)
// #define marpa_v_rule_start_es_id(v) ((v)->t_rule_start_ys_id)
// #define marpa_v_token_start_es_id(v) ((v)->t_token_start_ys_id)
// #define marpa_v_es_id(v) ((v)->t_ys_id)

--]]

function valuator_class.new(recognizer)

  local bocage = ffi.gc( C.marpa_b_new (recognizer.r, -1), C.marpa_b_unref )
  lib.assert( bocage, "marpa_b_new", recognizer.g )

  local order  = ffi.gc( C.marpa_o_new (bocage), C.marpa_o_unref )
  lib.assert( order, "marpa_o_new", recognizer.g )

  local tree   = ffi.gc( C.marpa_t_new (order), C.marpa_t_unref )
  lib.assert( tree, "marpa_t_new", recognizer.g )

  local tree_status = C.marpa_t_next (tree)
  lib.assert( tree_status, "marpa_t_next", recognizer.g )

  local value = ffi.gc( C.marpa_v_new (tree), marpa_v_unref )
  lib.assert( value, "marpa_v_new", recognizer.g )

  local valuator_object = { g = recognizer.g, r = recognizer.r, value = value }

  setmetatable( valuator_object, { __index =
    function (valuator_object, method)
      p("wrapper for ", method)
      return function (valuator_object, ...)

        local c_function = valuator_class[method]
        assert (c_function ~= nil, "No such method: " .. method)

        local result

        if method == '...' then

          local args = {...}

          return c_function(valuator_object.value, ...)

        else
          -- p("calling", method)
          result = c_function(valuator_object.value, ...)
        end
        -- throw exception on error
        lib.assert (result, "marpa_r_" .. method, valuator_object.g)
        -- return call result otherwise
        return result
      end
    end
  })

  return valuator_object

end

return valuator_class
