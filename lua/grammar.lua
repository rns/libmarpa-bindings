-- libmarpa binding
local lib   = require 'libmarpa'
local C     = lib.C
local ffi   = lib.ffi

--- debug helpers
local inspect = require 'inspect'
local i = inspect
local p = print

-- marpa_g_* methods
local grammar_class = { }

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
      -- otherwise use generic wrapper -- C function call + error checking
      return function (grammar_object, ...)
        return lib.call(grammar_object.g, "marpa_g_" .. method, grammar_object.g, ...)
      end
    end
  })

  return grammar_object

end

-- check if symbol s_str exists in the symbol table
-- call libmarpa method to add the symbol to the grammar if it doesn't
-- throw exception on error
-- return symbol id for s_str on success
function grammar_class.symbol_new(grammar_object, s_str)

  assert(type(s_str) == "string", "symbol must be a string")

  local symbols = grammar_object.symbols

  local s_id = symbols[s_str]
  if s_id == nil then
    s_id = lib.call(grammar_object.g, "marpa_g_symbol_new", grammar_object.g)
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

  return lib.call(grammar_object.g,
    "marpa_g_rule_new", grammar_object.g, lhs_id, rhs_ids, #RHS_IDs)

end

-- create a sequence rule translating the quantifier_char to
-- the numeric value required by libmarpa
-- call libmarpa method, throw exception on error
-- return new sequence rule id on success

-- flags are as defined libmarpa documentation

-- todo: support for '?' and {n,m} quantifiers in addition to '+' or '*',

local numeric_quantifiers = { ['+'] = 1, ['*'] = 0 }

function grammar_class.sequence_new
  (grammar_object, lhs_id, item_id, separator_id, quantifier_char, flags)

  local nq = numeric_quantifiers[quantifier_char]
  assert ( nq ~= nil, "quantifier_char can be either '+' or '*', not <" .. quantifier_char .. ">" )

  return lib.call(grammar_object.g,
    "marpa_g_sequence_new", grammar_object.g, lhs_id, item_id, separator_id, nq, flags)

end

return grammar_class
