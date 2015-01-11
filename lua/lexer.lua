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
  local token_start = 0
  local token_value
  local match

  return function(expected_terminals)

    if input == '' then return nil, nil, nil, nil end

    for _, triple in ipairs(token_spec) do

      pattern         = triple[1]
      token_symbol    = triple[2]
      token_symbol_id = triple[3]

      if expected_terminals[token_symbol] ~= nil or always_expected[token_symbol] ~= nil then
        match = string.match(input, "^" .. pattern)
        if match ~= nil then
          input = string.gsub(input, "^" .. pattern, "")
          break
        end
      end

    end

    assert( token_symbol ~= 'MISMATCH', string.format("Invalid token: <%s>", match ) )

    if token_symbol == 'NEWLINE' then
      column = 1
      line = line + 1
      token_start = token_start + 1
    elseif token_symbol == 'WHITESPACE' then
      column = column + string.len(match)
      token_start = token_start + string.len(match)
    else
      -- d.p(token_symbol, token_symbol_id, match, '@', token_start, ';', line, ':', column)
      token_length = string.len(match)
      column = column + token_length
      token_start = token_start + token_length
      token_value = match
    end

    return token_symbol, token_symbol_id, token_value, token_start, line, column
  end

end

