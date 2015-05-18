--[[
  location object prototype for the Kollos project
  according to
  https://github.com/rns/kollos-luif-doc/blob/master/d2l/spec.md
--]]

local luif = {}

local l = require 'location'

local function location()
  local info = debug.getinfo(3, "Sl")
  return l.new{
    blob = info.source,
    line = info.currentline
  }
end

function luif.G (grammar)
  local l = location()
  io.stderr:write(string.format("%s: %d\n", l.blob, l.line))
  return grammar
end

function luif.S (name)
  return "S:'" .. name .. "'"
end

function luif.L (literal)
  return "L:'" .. literal .. "'"
end

function luif.C (charclass)
  return "C:'" .. charclass .. "'"
end

function luif.Q (quantifier)
  return "Q:'" .. quantifier .. "'"
end

function luif.hide (...)
  return "hidden[ '" .. table.concat({...}, ' ') .. " ]"
end

function luif.group (...)
  return "hidden[ '" .. table.concat({...}, ' ') .. " ]"
end

return luif
