-- return iterator

local _, rex = pcall (require,"rex_pcre")

lexer = { }
--[[
options
  tokens
    token specification table
  input
    input string
todo:
  patterns
    lua
    pcre
  matching
    ft first token
    lt longest token
    fat first acceptable token
    lat longest acceptable token
      default
  ambiguity
    fatal
    warn
    allow

]]--

function lexer.new (options)

  local token_spec = options.tokens
  local input = options.input
  local patterns = options.patterns or 'pcre'

  local line   = 1
  local column = 1

  local token_start = 1
  local token_length = 0

  -- set matcher
  local matcher
  if patterns == 'lua' then
    matcher = lexer.lua_pattern_first_acceptable_token_match
  elseif patterns == 'pcre' then
    local token_id = {}
    local token_regex = {}
    for _, triple in ipairs(token_spec) do
      --pti (triple[2], triple[1])
      token_id[triple[2]] = triple[3]
      table.insert(token_regex, string.format("(?P<%s>%s)", triple[2], triple[1] ) )
    end
    lexer.token_regex = table.concat(token_regex, '|')
    --pti(lexer.token_regex)
    lexer.token_regex = rex.new(lexer.token_regex)
    lexer.token_id = token_id
    --pti(lexer.token_id)
    matcher = lexer.pcre_first_acceptable_token_match
  else
    assert( false, 'patterns must be set to "lua" or "pcre" not ' .. '"' .. patterns .. '"')
  end

  return function(expected_terminals)

    token_start = token_start + token_length
    if token_start > string.len(input) then return nil end

    local match, token_symbol, token_symbol_id = matcher(token_spec, expected_terminals, input, token_start)
    token_length = string.len(match)

    if token_symbol == 'NEWLINE' then
      column = 1
      line = line + 1
    else
      -- todo: count newlines in match, if any
      -- unless, e.g. they are in quotes
      -- so perhaps absolute position in input, like Marpa::R2 is better
    end

--    pt(token_symbol, token_symbol_id, match, token_start, ':', token_length, line, column)
-- todo: line/column as instance members
    return token_symbol, token_symbol_id, token_start, token_length, line, column
  end

end

--[[
  todo:
    first token match
      regex-only (not lua patterns)
      token regexes concatenated with |
    first acceptable token match
      order in important
    longest acceptable token match
      order in unimportant -- all expected tokens will be matched
    ambiguous token match
      several tokens of the same length
        1.1
          number
          list numbering
      say
        keyword
        identifier
      have the same length, return all variants
    lexeme priorities
      say keyword or id
    preserving whitespaces (to test against input cleanly)
    preserving comments

    try marpa_r_terminal_is_expected() -- http://irclog.perlgeek.de/marpa/2015-01-11#i_9918855
]]--

function lexer.lua_pattern_first_acceptable_token_match(token_spec, expected_terminals, input, token_start)
  local pattern
  local token_symbol
  local token_symbol_id
  for _, triple in ipairs(token_spec) do
    pattern         = triple[1]
    token_symbol    = triple[2]
    token_symbol_id = triple[3]
    if expected_terminals[token_symbol] ~= nil then
      -- doesn't work without "^" somehow despite specifying start pos token_start
      match = string.match(input, "^" .. pattern, token_start)
      if match ~= nil then
        return match, token_symbol, token_symbol_id
      end
    end
  end
end

function lexer.pcre_first_acceptable_token_match_slow(token_spec, expected_terminals, input, token_start)
  local pattern
  local token_symbol
  local token_symbol_id
  for _, triple in ipairs(token_spec) do
    pattern         = triple[1]
    token_symbol    = triple[2]
    token_symbol_id = triple[3]
    if expected_terminals[token_symbol] ~= nil then
      -- pti(pattern .. ' @' .. token_start)
      local re = rex.new( '(' .. pattern .. ')' )
      local s, e, match = re:find(input, token_start)
      if s ~= nil and s == token_start then
        return match, token_symbol, token_symbol_id
      end
    end
  end
end

function lexer.pcre_first_acceptable_token_match(token_spec, expected_terminals, input, token_start)
  local s, e, matches = lexer.token_regex:tfind(input, token_start)
--  pi(s, e, matches)
  for token_ix, match in ipairs(matches) do
--    pi(token_ix, match)
    if match then
      return match, token_spec[token_ix][2], token_spec[token_ix][3]
    end
  end
end
