-- libmarpa binding
local lib   = require 'libmarpa'
local C     = lib.C
local ffi   = lib.ffi

--- debug helpers
local inspect = require 'inspect'
local i = inspect
local p = print

-- marpa_r_* methods
local recognizer_class = {
  start_input = C.marpa_r_start_input,
  alternative = C.marpa_r_alternative,
  earleme_complete = C.marpa_r_earleme_complete,
  current_earleme = C.marpa_r_current_earleme,
  earleme = C.marpa_r_earleme,
  earley_set_value = C.marpa_r_earley_set_value,
  earley_set_values = C.marpa_r_earley_set_values,
  furthest_earleme = C.marpa_r_furthest_earleme,
  latest_earley_set = C.marpa_r_latest_earley_set,
  latest_earley_set_value_set = C.marpa_r_latest_earley_set_value_set,
  latest_earley_set_values_set = C.marpa_r_latest_earley_set_values_set,
  earley_item_warning_threshold = C.marpa_r_earley_item_warning_threshold,
  earley_item_warning_threshold_set = C.marpa_r_earley_item_warning_threshold_set,
  expected_symbol_event_set = C.marpa_r_expected_symbol_event_set,
  is_exhausted = C.marpa_r_is_exhausted,
  terminals_expected = C.marpa_r_terminals_expected,
  terminal_is_expected = C.marpa_r_terminal_is_expected,
  completion_symbol_activate = C.marpa_r_completion_symbol_activate,
  nulled_symbol_activate = C.marpa_r_nulled_symbol_activate,
  prediction_symbol_activate = C.marpa_r_prediction_symbol_activate,
  progress_report_reset = C.marpa_r_progress_report_reset,
  progress_report_start = C.marpa_r_progress_report_start,
  progress_report_finish = C.marpa_r_progress_report_finish,
  progress_item = C.marpa_r_progress_item,
}

function recognizer_class.new(grammar)

  local r = ffi.gc( C.marpa_r_new(grammar.g), C.marpa_r_unref )
  lib.assert( r, "marpa_r_new", grammar.g )

  local recognizer_object = { g = grammar.g, r = r }

  setmetatable( recognizer_object, { __index =
    function (recognizer_object, method)
      -- p("wrapper caller for ", method)
      return function (recognizer_object, ...)

        local c_function = recognizer_class[method]
        assert (c_function ~= nil, "No such method: " .. method)

        local result

        if method == 'alternative' then

          local args = {...}

          return c_function(recognizer_object.r, ...)

        else
          -- p("calling", method)
          result = c_function(recognizer_object.r, ...)
        end
        -- throw exception on error
        lib.assert (result, "marpa_r_" .. method, recognizer_object.g)
        -- return call result otherwise
        return result
      end
    end
  })

  return recognizer_object

end

return recognizer_class
