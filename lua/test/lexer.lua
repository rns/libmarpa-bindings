#!/usr/bin/lua
require 'Test.More'

package.path = "../?.lua;" .. package.path

if not require_ok 'lexer' then
    BAIL_OUT "no lexer"
end

-- tokenize json string input using token_spec ts

local input = '[ 1, "abc\ndef",\n-2.3, null, [], true, false, [1,2,3], {}, {"a":1,"b":2} ]'

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
  { '[ \t]+', 'WHITESPACE', -1 },  -- Skip over spaces and tabs
  { "\n", 'NEWLINE',  -1 },  -- Line endings
  { '.', 'MISMATCH', -1 }   -- Any other character
}

local lex = lexer.new{ tokens = ts, input = input }

local expected_tokens = { { "lsquare", 15, 1, 1, 1, 1 }, { "WHITESPACE", -1, 2, 1, 1, 1 }, { "number", 9, 3, 1, 1, 1 }, { "comma", 5, 4, 1, 1, 1 }, { "WHITESPACE", -1, 5, 1, 1, 1 }, { "string", 8, 6, 9, 1, 1 }, { "comma", 5, 15, 1, 1, 1 }, { "NEWLINE", -1, 16, 1, 2, 1 }, { "number", 9, 17, 4, 2, 1 }, { "comma", 5, 21, 1, 2, 1 }, { "WHITESPACE", -1, 22, 1, 2, 1 }, { "null", 13, 23, 4, 2, 1 }, { "comma", 5, 27, 1, 2, 1 }, { "WHITESPACE", -1, 28, 1, 2, 1 }, { "lsquare", 15, 29, 1, 2, 1 }, { "rsquare", 16, 30, 1, 2, 1 }, { "comma", 5, 31, 1, 2, 1 }, { "WHITESPACE", -1, 32, 1, 2, 1 }, { "true", 11, 33, 4, 2, 1 }, { "comma", 5, 37, 1, 2, 1 }, { "WHITESPACE", -1, 38, 1, 2, 1 }, { "false", 12, 39, 5, 2, 1 }, { "comma", 5, 44, 1, 2, 1 }, { "WHITESPACE", -1, 45, 1, 2, 1 }, { "lsquare", 15, 46, 1, 2, 1 }, { "number", 9, 47, 1, 2, 1 }, { "comma", 5, 48, 1, 2, 1 }, { "number", 9, 49, 1, 2, 1 }, { "comma", 5, 50, 1, 2, 1 }, { "number", 9, 51, 1, 2, 1 }, { "rsquare", 16, 52, 1, 2, 1 }, { "comma", 5, 53, 1, 2, 1 }, { "WHITESPACE", -1, 54, 1, 2, 1 }, { "lcurly", 1, 55, 1, 2, 1 }, { "rcurly", 2, 56, 1, 2, 1 }, { "comma", 5, 57, 1, 2, 1 }, { "WHITESPACE", -1, 58, 1, 2, 1 }, { "lcurly", 1, 59, 1, 2, 1 }, { "string", 8, 60, 3, 2, 1 }, { "colon", 17, 63, 1, 2, 1 }, { "number", 9, 64, 1, 2, 1 }, { "comma", 5, 65, 1, 2, 1 }, { "string", 8, 66, 3, 2, 1 }, { "colon", 17, 69, 1, 2, 1 }, { "number", 9, 70, 1, 2, 1 }, { "rcurly", 2, 71, 1, 2, 1 }, { "WHITESPACE", -1, 72, 1, 2, 1 }, { "rsquare", 16, 73, 1, 2, 1 } }

local i = 1
local expected_termninals = {} for _, v in pairs(ts) do expected_termninals[v[2]] = 1 end
note("tokenizing\n" .. input)
while true do
  local token_symbol, token_symbol_id, token_start, token_length, line, column = lex(expected_termninals)
  if token_symbol == nil then break end
  is_deeply(
    { token_symbol, token_symbol_id, token_start, token_length, line, column },
    expected_tokens[i],
    "json token " .. sf("{ '%s', S%d, '%s', %s, %s, %s },", token_symbol, token_symbol_id, token_start, token_length, line, column)
  )
  i = i + 1
end
note("tokenized")

done_testing()
