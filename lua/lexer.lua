-- return iterator
require 'printf_debugging';

lexer = { }
function lexer.new (token_specification, input)

  local token_spec = token_specification
  local input = input

  -- add
  local S_none = -1
  local aux_tokens = {
    [1] = {'[ \t]+',  'WHITESPACE',     S_none},  -- Skip over spaces and tabs
    [2] = {"\n",      'NEWLINE',  S_none},  -- Line endings
    [3] = {'.',       'MISMATCH', S_none}   -- Any other character
  }
  for i, v in ipairs(aux_tokens) do
    table.insert( token_spec, v )
  end

  local line   = 1
  local column = 1
  -- these terminals must always be matched
  local always_expected = { WHITESPACE = 1, NEWLINE = 1, MISMATCH = 1 }

  local pattern
  local token_symbol
  local token_symbol_id
  local token_start = 1
  local token_length = 0

  return function(expected_terminals)

    token_start = token_start + token_length
    if token_start > string.len(input) then return nil end

-- start matcher
--[[
  todo:
    implement matchers for
      first match               -- fastest, manual longest-first arrangement
        with regex, single match of lexemes with ()|<()
        with lua patterns, loop
      longest match
      longest acceptable match
        loop with both regex and patterns
      ambiguous lexing
    lexeme priorities
      say keyword or id
    preserving whitespaces (to test against inpout cleanly)
    preserving comments
]]--
    local match
    for _, triple in ipairs(token_spec) do
      pattern         = triple[1]
      token_symbol    = triple[2]
      token_symbol_id = triple[3]
      if expected_terminals[token_symbol] ~= nil or always_expected[token_symbol] ~= nil then
        -- doesn't work without "^" somehow despite specifying start pos token_start
        match = string.match(input, "^" .. pattern, token_start)
        if match ~= nil then
          token_length = string.len(match)
          break
        end
      end
    end
-- end matcher

    if token_symbol == 'NEWLINE' then
      column = 1
      line = line + 1
    end

--    pt(token_symbol, token_symbol_id, match, token_start, ':', token_length, line, column)
-- todo: line/column as instance members
    return token_symbol, token_symbol_id, token_start, token_length, line, column
  end

end

