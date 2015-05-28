-- libmarpa binding
local lib   = require 'libmarpa'
local C     = lib.C
local ffi   = lib.ffi

--- debug helpers
local inspect = require 'inspect'
local i = inspect
local p = print

local recognizer_class = { }

function recognizer_class.new(grammar)

  local r = ffi.gc( C.marpa_r_new(grammar.g), C.marpa_r_unref )
  lib.assert( r, "marpa_r_new", grammar.g )

  local recognizer_object = { g = grammar.g, r = r }

  setmetatable( recognizer_object, { __index =
    function (recognizer_object, method)
      -- if class provides a wrapper, return it
      local class_method = recognizer_class[method]
      if class_method ~= nil then
        return function (recognizer_object, ...) return class_method(recognizer_object, ...) end
      end
      -- otherwise use generic wrapper -- C function call + error checking
      return function (recognizer_object, ...)
        return lib.call(recognizer_object.g, "marpa_r_" .. method, recognizer_object.r, ...)
      end
    end
  })

  return recognizer_object

end

function recognizer_class.alternative(recognizer_object, token_symbol, token_start)
  local result = C.marpa_r_alternative(recognizer_object.r, token_symbol, token_start, 1)
  if (result == C.MARPA_ERR_UNEXPECTED_TOKEN_ID) then return nil end
  if (result == C.MARPA_ERR_NONE) then return 1 end
  lib.assert(result, "marpa_r_alternative", recognizer_object.g);
end

return recognizer_class
