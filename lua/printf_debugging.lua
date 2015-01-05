printf_debugging = {}

-- debug "with print statements" helpers
local inspect = require 'inspect'
function printf_debugging.sf(...) return string.format(...) end
function printf_debugging.t(l)
  local info = debug.getinfo(l, "Sl")
  return printf_debugging.sf("%s:%d", info.short_src, info.currentline)
end
function printf_debugging.i(...)
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
function printf_debugging.s(...) return inspect(...) end
function printf_debugging.p(...) print(...) end
function printf_debugging.pi(...) printf_debugging.p(printf_debugging.i(...)) end
function printf_debugging.pt(...) printf_debugging.p(... .. " at " .. printf_debugging.t(3)) end
function printf_debugging.pti(...) printf_debugging.p(printf_debugging.i(...) .. " at " .. printf_debugging.t(3)) end

return printf_debugging
