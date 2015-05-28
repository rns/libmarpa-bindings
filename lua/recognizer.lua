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
      return lib.__index(recognizer_class, recognizer_object, method, "marpa_r_", recognizer_object.r)
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
