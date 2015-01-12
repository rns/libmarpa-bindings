require 'lexer'

local ts = {
  { "{", "lcurly", 1 },
  { "}", "rcurly", 2 },
  { "%[", "lsquare", 15 },
  { "%]", "rsquare", 16 },
  { ",", "comma", 5 },
  { ":", "colon", 17 },
  { '"[^"]+"', "string", 8 },
  { "-?[%d]+[.%d+]*",   "number", 9 },
  { "true", "true", 11 },
  { "false", "false", 12 },
  { "null", "null", 13 },
}

local input = '[ 1, "abc\ndef",\n-2.3, null, [], true, false, [1,2,3], {}, {"a":1,"b":2} ]'
local lex = lexer.new{ tokens = ts, input = input }

local et = {}
for _, v in pairs(ts) do et[v[2]] = 1 end

local i = 0
local imax = 70

while true do

  local token_symbol, token_symbol_id, token_start, token_length, line, column = lex(et)
  if token_symbol == nil then break end
  p(sf("{ '%s', S%d, '%s', %s, %s, %s },", token_symbol, token_symbol_id, token_start, token_length, line, column))

  i = i + 1
  if i > imax then print("max iteration count " .. imax .." exceeded") break end
end
