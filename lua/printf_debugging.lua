-- debug "with print statements" helpers
local inspect = require 'inspect'
function sf(...) return string.format(...) end
function t(l)
  local info = debug.getinfo(l, "Sl")
  return sf("%s:%d", info.short_src, info.currentline)
end
function i(...)
  local inspected = {}
  for ix, value in ipairs({...}) do
    -- based on http://stackoverflow.com/questions/10458306/get-name-of-argument-of-function-in-lua
    local name = ''
    -- see if we can find a local in the caller's scope with the given value
    for i=1,math.huge do
      local localname, localvalue = debug.getlocal(2,i,1)
      if not localname then
        break
      elseif localvalue == value then
        name = localname
      end
    end
    inspected[ix] = (name ~= '' and name .. ': ' or '') .. inspect(value)
  end
  return table.concat(inspected, '; ')
end
function s(...)
  local s = ""
  for i,v in ipairs({...}) do
    s = s .. ( type(v) == "table" and inspect(v) or tostring(v) ) .. "\t"
  end
  return s
end
function p(...) print(s(...)) end
function pi(...) p(i(...)) end
function pt(...) p(s(...), " at " .. t(3)) end
function pti(...) p(i(...) .. " at " .. t(3)) end

return { sf = sf, s = s, i = i, p = p, pi = pi, pt = pt, pti = pti }
