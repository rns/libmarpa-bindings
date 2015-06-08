#!/usr/bin/lua
require 'Test.More'

package.path = "../?.lua;../../?.lua;" .. package.path

local grammar = require 'grammar'

local g = grammar.new()

local S1 = g:symbol_new('S1')
ok ( S1 >= 0, 'symbol' )

local S2 = g:symbol_new('S2')
ok ( S2 >= 0, 'symbol' )

local R = g:rule_new( S1, { S2 } )
ok ( R >= 0, 'rule' )

local S3 = g:symbol_new('S3')
ok ( S3 >= 0, 'symbol' )

local S = g:sequence_new(S3, S2, -1, '+', 2)
ok ( S >= 0, 'unseparated sequence rule' )

g:start_symbol_set(S1)
ok ( g:start_symbol() >= 0, "start symbol set" )

g:precompute()

is ( g:is_precomputed(), 1, "precomputed" )

done_testing()
