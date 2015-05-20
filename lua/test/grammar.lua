#!/usr/bin/lua
require 'Test.More'

package.path = "../?.lua;" .. package.path

local grammar = require 'grammar'

local g = grammar:new()

local S1 = g:symbol_new()
local S2 = g:symbol_new()
diag (S1, S2)

local R = g:rule_new(S1, { S2 })

diag (R)

g:start_symbol_set(S1)
assert( g:start_symbol() >= 0, "Start symbol not set" )

g:precompute()

is ( g:is_precomputed(), 1, "precomputed" )
