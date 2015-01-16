#!/usr/bin/lua
require 'Test.More'

package.path = "../?.lua;" .. package.path

local lib   = require 'libmarpa'
local C     = lib.C
local ffi   = lib.ffi

-- take an archetypal Libmarpa application and simulate errors in it
-- as far as possible or just call lib.assert with appropriate codes
-- but libmarpa functions are still called, for pedantry :)

local ret_or_err

-- Marpa configurarion
local config = ffi.new("Marpa_Config")
C.marpa_c_init(config) -- always succeeds
_, ret_or_err = pcall(lib.assert, -1, "marpa_c_init", config)
like(ret_or_err, "marpa_c_init returned 0: MARPA_ERR_NONE: No error", "marpa_c_init" )

-- grammar
local g = ffi.gc(C.marpa_g_new(config), C.marpa_g_unref)
_, ret_or_err = pcall(lib.assert, ffi.NULL, "marpa_g_new", config)
like(ret_or_err, "marpa_g_new returned 0: MARPA_ERR_NONE: No error", "marpa_g_new" )

-- turn off a deprecated feature
C.marpa_g_force_valued(g)
_, ret_or_err = pcall(lib.assert, -1, "marpa_g_force_valued", g )
like(ret_or_err, "marpa_g_force_valued returned 0: MARPA_ERR_NONE: No error", "marpa_g_force_valued" )

-- the grammar is now empty (nor rules, nor symbols)
_, ret_or_err = pcall(lib.assert, C.marpa_g_start_symbol(g), "marpa_g_start_symbol", g )
like(
  ret_or_err,
  "marpa_g_start_symbol returned 43: MARPA_ERR_NO_START_SYMBOL: This grammar has no start symbol",
  "marpa_g_start_symbol on an empty or otherwise non-precomputed grammar"
)

_, ret_or_err = pcall(lib.assert, C.marpa_g_precompute(g), "marpa_g_precompute", g )
like(
  ret_or_err,
  "marpa_g_precompute returned 42: MARPA_ERR_NO_RULES: This grammar does not have any rules",
  "marpa_g_precompute on an empty grammar"
)

-- symbols
local S_lhs = C.marpa_g_symbol_new (g)
_, ret_or_err = pcall(lib.assert, -2, "marpa_g_symbol_new", g )
like(
  ret_or_err,
  "marpa_g_symbol_new returned 0: MARPA_ERR_NONE: No error",
  "marpa_g_symbol_new"
)

local S_rhs1 = C.marpa_g_symbol_new (g)
lib.assert(S_rhs1, "marpa_g_symbol_new", g)

-- rules
local rhs = ffi.new("int[4]")

rhs[0] = S_rhs1
local R_new = C.marpa_g_rule_new (g, S_lhs, rhs, 1)
lib.assert( R_new, "marpa_g_rule_new", g )

-- new rule
local R_duplicated = C.marpa_g_rule_new (g, S_lhs, rhs, 1)
_, ret_or_err = pcall( lib.assert, R_duplicated, "marpa_g_rule_new", g )
like(
  ret_or_err,
  "marpa_g_rule_new returned 11: MARPA_ERR_DUPLICATE_RULE: Duplicate rule",
  "marpa_g_rule_new"
)

-- sequence accessor rules
local rc

lib.assert( C.marpa_g_start_symbol_set(g, S_lhs), "marpa_g_start_symbol_set", g)
lib.assert( C.marpa_g_precompute(g), "marpa_g_precompute", g)

rc = C.marpa_g_sequence_separator(g, R_new)
_, ret_or_err = pcall(lib.assert, rc, "marpa_g_sequence_separator", g)
like(
  ret_or_err,
  "marpa_g_sequence_separator returned 201: MARPA_ERR_RULE_IS_NOT_SEQUENCE: Rule is not a sequence rule",
  "marpa_g_sequence_separator"
)

-- grammar to test sequance rules errors
local g_seq = ffi.gc(C.marpa_g_new(config), C.marpa_g_unref)

local S_seq = lib.assert( C.marpa_g_symbol_new(g_seq), "marpa_g_symbol_new", g_seq )
local S_item = lib.assert( C.marpa_g_symbol_new(g_seq), "marpa_g_symbol_new", g_seq )
local S_separator = lib.assert( C.marpa_g_symbol_new(g_seq), "marpa_g_symbol_new", g_seq )

local R_seq = lib.assert(
  C.marpa_g_sequence_new (
    g_seq, S_seq, S_item, S_separator, 0, C.MARPA_PROPER_SEPARATION
  ), "marpa_g_sequence_new", g_seq
)

_, ret_or_err = pcall(lib.assert, C.marpa_g_sequence_separator(g_seq, R_seq-1), "marpa_g_sequence_separator", g_seq)
like(
  ret_or_err,
  "marpa_g_sequence_separator returned 26: MARPA_ERR_INVALID_RULE_ID: Rule ID is malformed",
  "marpa_g_sequence_separator"
)

lib.assert( C.marpa_g_start_symbol_set(g_seq, S_lhs), "marpa_g_start_symbol_set", g_seq)
lib.assert( C.marpa_g_precompute(g_seq), "marpa_g_precompute", g_seq)

local r = C.marpa_r_new ( g_seq )
lib.assert( r, "marpa_r_new", g_seq )

_, ret_or_err = pcall(lib.assert, C.marpa_r_alternative(r, S_item, 1, 1), "marpa_r_alternative", g_seq)

like(
  ret_or_err,
  "marpa_r_alternative returned 60: MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT: The recognizer is not accepting input",
  "marpa_r_alternative"
)

done_testing()
