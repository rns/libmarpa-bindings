#!env lua

require 'Test.More'

package.path = "../?.lua;" .. package.path

if not require_ok 'location' then
    BAIL_OUT "can't require location"
end

local location = require 'location'

local info = debug.getinfo(1, "Sl")

local l = location.new{
  blob = info.source,
  line = info.currentline
}

is(l.blob, info.source, "source")

is(l.line, info.currentline, "current line")

