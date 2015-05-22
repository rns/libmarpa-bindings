#!env lua

local t = require 'Test.More'

package.path = "../?.lua;" .. package.path

if not t.require_ok 'location' then
    t.BAIL_OUT "can't require location"
end

local location = require 'location'

local info = debug.getinfo(1, "Sl")

local l = location.new{
  blob = info.source,
  line = info.currentline
}

t.is(l.blob, info.source, "source")

t.is(l.line, info.currentline, "current line")

t.is(l:location(), info.source .. ': ' .. info.currentline, "location()")

t.is(string.format("%s", l), info.source .. ': ' .. info.currentline, "__tostring")

t.done_testing()
