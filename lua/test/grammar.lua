#!/usr/bin/lua
require 'Test.More'

package.path = "../?.lua;" .. package.path

local grammar = require 'grammar'

local g = grammar.new()

local S1 = g:symbol_new()
local S2 = g:symbol_new()

local R = g:rule_new(S1, { S2 })

g:start_symbol_set(S1)
ok ( g:start_symbol() >= 0, "start symbol set" )

g:precompute()

is ( g:is_precomputed(), 1, "precomputed" )
