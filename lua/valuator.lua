-- libmarpa binding
local lib   = require 'libmarpa'
local C     = lib.C
local ffi   = lib.ffi

--- debug helpers
local inspect = require 'inspect'
local i = inspect
local p = print

local valuator_class = { }

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
      -- if class provides a wrapper, return it
      local class_method = valuator_class[method]
      if class_method ~= nil then
        return function (valuator_object, ...) return class_method(valuator_object, ...) end
      end
      -- otherwise use generic wrapper -- C function call + error checking
      return function (valuator_object, ...)
        return lib.call(valuator_object.g, "marpa_v_" .. method, valuator_object.value, ...)
      end
    end
  })

  return valuator_object

end

return valuator_class
