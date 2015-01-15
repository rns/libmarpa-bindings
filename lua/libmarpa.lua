--[[
  Lua ffi binding to libmarpa
  Prerequisites:
    libmarpa -- https://github.com/jeffreykegler/libmarpa -- built as a shared library
    LuaJIT 2.0.3 -- http://luajit.org/download.html

 /*
  * This file is based on Libmarpa, Copyright 2014 Jeffrey Kegler.
  * Libmarpa is free software: you can
  * redistribute it and/or modify it under the terms of the GNU Lesser
  * General Public License as published by the Free Software Foundation,
  * either version 3 of the License, or (at your option) any later version.
  *
  * Libmarpa is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  * Lesser General Public License for more details.
  *
  * You should have received a copy of the GNU Lesser
  * General Public License along with Libmarpa.  If not, see
  * http://www.gnu.org/licenses/.
  */
]]--

local _errors = {
  { 0, "MARPA_ERR_NONE", "No error" },
  { 1, "MARPA_ERR_AHFA_IX_NEGATIVE", "MARPA_ERR_AHFA_IX_NEGATIVE" },
  { 2, "MARPA_ERR_AHFA_IX_OOB", "MARPA_ERR_AHFA_IX_OOB" },
  { 3, "MARPA_ERR_ANDID_NEGATIVE", "MARPA_ERR_ANDID_NEGATIVE" },
  { 4, "MARPA_ERR_ANDID_NOT_IN_OR", "MARPA_ERR_ANDID_NOT_IN_OR" },
  { 5, "MARPA_ERR_ANDIX_NEGATIVE", "MARPA_ERR_ANDIX_NEGATIVE" },
  { 6, "MARPA_ERR_BAD_SEPARATOR", "Separator has invalid symbol ID" },
  { 7, "MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED", "MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED" },
  { 8, "MARPA_ERR_COUNTED_NULLABLE", "Nullable symbol on RHS of a sequence rule" },
  { 9, "MARPA_ERR_DEVELOPMENT", "Development error, see string" },
  { 10, "MARPA_ERR_DUPLICATE_AND_NODE", "MARPA_ERR_DUPLICATE_AND_NODE" },
  { 11, "MARPA_ERR_DUPLICATE_RULE", "Duplicate rule" },
  { 12, "MARPA_ERR_DUPLICATE_TOKEN", "Duplicate token" },
  { 13, "MARPA_ERR_YIM_COUNT", "Maximum number of Earley items exceeded" },
  { 14, "MARPA_ERR_YIM_ID_INVALID", "MARPA_ERR_YIM_ID_INVALID" },
  { 15, "MARPA_ERR_EVENT_IX_NEGATIVE", "Negative event index" },
  { 16, "MARPA_ERR_EVENT_IX_OOB", "No event at that index" },
  { 17, "MARPA_ERR_GRAMMAR_HAS_CYCLE", "Grammar has cycle" },
  { 18, "MARPA_ERR_INACCESSIBLE_TOKEN", "Token symbol is inaccessible" },
  { 19, "MARPA_ERR_INTERNAL", "MARPA_ERR_INTERNAL" },
  { 20, "MARPA_ERR_INVALID_AHFA_ID", "MARPA_ERR_INVALID_AHFA_ID" },
  { 21, "MARPA_ERR_INVALID_AIMID", "MARPA_ERR_INVALID_AIMID" },
  { 22, "MARPA_ERR_INVALID_BOOLEAN", "Argument is not boolean" },
  { 23, "MARPA_ERR_INVALID_IRLID", "MARPA_ERR_INVALID_IRLID" },
  { 24, "MARPA_ERR_INVALID_NSYID", "MARPA_ERR_INVALID_NSYID" },
  { 25, "MARPA_ERR_INVALID_LOCATION", "Location is not valid" },
  { 26, "MARPA_ERR_INVALID_RULE_ID", "Rule ID is malformed" },
  { 27, "MARPA_ERR_INVALID_START_SYMBOL", "Specified start symbol is not valid" },
  { 28, "MARPA_ERR_INVALID_SYMBOL_ID", "Symbol ID is malformed" },
  { 29, "MARPA_ERR_I_AM_NOT_OK", "Marpa is in a not OK state" },
  { 30, "MARPA_ERR_MAJOR_VERSION_MISMATCH", "Libmarpa major version number is a mismatch" },
  { 31, "MARPA_ERR_MICRO_VERSION_MISMATCH", "Libmarpa micro version number is a mismatch" },
  { 32, "MARPA_ERR_MINOR_VERSION_MISMATCH", "Libmarpa minor version number is a mismatch" },
  { 33, "MARPA_ERR_NOOKID_NEGATIVE", "MARPA_ERR_NOOKID_NEGATIVE" },
  { 34, "MARPA_ERR_NOT_PRECOMPUTED", "This grammar is not precomputed" },
  { 35, "MARPA_ERR_NOT_TRACING_COMPLETION_LINKS", "MARPA_ERR_NOT_TRACING_COMPLETION_LINKS" },
  { 36, "MARPA_ERR_NOT_TRACING_LEO_LINKS", "MARPA_ERR_NOT_TRACING_LEO_LINKS" },
  { 37, "MARPA_ERR_NOT_TRACING_TOKEN_LINKS", "MARPA_ERR_NOT_TRACING_TOKEN_LINKS" },
  { 38, "MARPA_ERR_NO_AND_NODES", "MARPA_ERR_NO_AND_NODES" },
  { 39, "MARPA_ERR_NO_EARLEY_SET_AT_LOCATION", "Earley set ID is after latest Earley set" },
  { 40, "MARPA_ERR_NO_OR_NODES", "MARPA_ERR_NO_OR_NODES" },
  { 41, "MARPA_ERR_NO_PARSE", "No parse" },
  { 42, "MARPA_ERR_NO_RULES", "This grammar does not have any rules" },
  { 43, "MARPA_ERR_NO_START_SYMBOL", "This grammar has no start symbol" },
  { 44, "MARPA_ERR_NO_TOKEN_EXPECTED_HERE", "No token is expected at this earleme location" },
  { 45, "MARPA_ERR_NO_TRACE_YIM", "MARPA_ERR_NO_TRACE_YIM" },
  { 46, "MARPA_ERR_NO_TRACE_YS", "MARPA_ERR_NO_TRACE_YS" },
  { 47, "MARPA_ERR_NO_TRACE_PIM", "MARPA_ERR_NO_TRACE_PIM" },
  { 48, "MARPA_ERR_NO_TRACE_SRCL", "MARPA_ERR_NO_TRACE_SRCL" },
  { 49, "MARPA_ERR_NULLING_TERMINAL", "A symbol is both terminal and nulling" },
  { 50, "MARPA_ERR_ORDER_FROZEN", "The ordering is frozen" },
  { 51, "MARPA_ERR_ORID_NEGATIVE", "MARPA_ERR_ORID_NEGATIVE" },
  { 52, "MARPA_ERR_OR_ALREADY_ORDERED", "MARPA_ERR_OR_ALREADY_ORDERED" },
  { 53, "MARPA_ERR_PARSE_EXHAUSTED", "The parse is exhausted" },
  { 54, "MARPA_ERR_PARSE_TOO_LONG", "This input would make the parse too long" },
  { 55, "MARPA_ERR_PIM_IS_NOT_LIM", "MARPA_ERR_PIM_IS_NOT_LIM" },
  { 56, "MARPA_ERR_POINTER_ARG_NULL", "An argument is null when it should not be" },
  { 57, "MARPA_ERR_PRECOMPUTED", "This grammar is precomputed" },
  { 58, "MARPA_ERR_PROGRESS_REPORT_EXHAUSTED", "The progress report is exhausted" },
  { 59, "MARPA_ERR_PROGRESS_REPORT_NOT_STARTED", "No progress report has been started" },
  { 60, "MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT", "The recognizer is not accepting input" },
  { 61, "MARPA_ERR_RECCE_NOT_STARTED", "The recognizer has not been started" },
  { 62, "MARPA_ERR_RECCE_STARTED", "The recognizer has been started" },
  { 63, "MARPA_ERR_RHS_IX_NEGATIVE", "RHS index cannot be negative" },
  { 64, "MARPA_ERR_RHS_IX_OOB", "RHS index must be less than rule length" },
  { 65, "MARPA_ERR_RHS_TOO_LONG", "The RHS is too long" },
  { 66, "MARPA_ERR_SEQUENCE_LHS_NOT_UNIQUE", "LHS of sequence rule would not be unique" },
  { 67, "MARPA_ERR_SOURCE_TYPE_IS_AMBIGUOUS", "MARPA_ERR_SOURCE_TYPE_IS_AMBIGUOUS" },
  { 68, "MARPA_ERR_SOURCE_TYPE_IS_COMPLETION", "MARPA_ERR_SOURCE_TYPE_IS_COMPLETION" },
  { 69, "MARPA_ERR_SOURCE_TYPE_IS_LEO", "MARPA_ERR_SOURCE_TYPE_IS_LEO" },
  { 70, "MARPA_ERR_SOURCE_TYPE_IS_NONE", "MARPA_ERR_SOURCE_TYPE_IS_NONE" },
  { 71, "MARPA_ERR_SOURCE_TYPE_IS_TOKEN", "MARPA_ERR_SOURCE_TYPE_IS_TOKEN" },
  { 72, "MARPA_ERR_SOURCE_TYPE_IS_UNKNOWN", "MARPA_ERR_SOURCE_TYPE_IS_UNKNOWN" },
  { 73, "MARPA_ERR_START_NOT_LHS", "Start symbol not on LHS of any rule" },
  { 74, "MARPA_ERR_SYMBOL_VALUED_CONFLICT", "Symbol is treated both as valued and unvalued" },
  { 75, "MARPA_ERR_TERMINAL_IS_LOCKED", "The terminal status of the symbol is locked" },
  { 76, "MARPA_ERR_TOKEN_IS_NOT_TERMINAL", "Token symbol must be a terminal" },
  { 77, "MARPA_ERR_TOKEN_LENGTH_LE_ZERO", "Token length must greater than zero" },
  { 78, "MARPA_ERR_TOKEN_TOO_LONG", "Token is too long" },
  { 79, "MARPA_ERR_TREE_EXHAUSTED", "Tree iterator is exhausted" },
  { 80, "MARPA_ERR_TREE_PAUSED", "Tree iterator is paused" },
  { 81, "MARPA_ERR_UNEXPECTED_TOKEN_ID", "Unexpected token" },
  { 82, "MARPA_ERR_UNPRODUCTIVE_START", "Unproductive start symbol" },
  { 83, "MARPA_ERR_VALUATOR_INACTIVE", "Valuator inactive" },
  { 84, "MARPA_ERR_VALUED_IS_LOCKED", "The valued status of the symbol is locked" },
  { 85, "MARPA_ERR_RANK_TOO_LOW", "Rule or symbol rank too low" },
  { 86, "MARPA_ERR_RANK_TOO_HIGH", "Rule or symbol rank too high" },
  { 87, "MARPA_ERR_SYMBOL_IS_NULLING", "Symbol is nulling" },
  { 88, "MARPA_ERR_SYMBOL_IS_UNUSED", "Symbol is not used" },
  { 89, "MARPA_ERR_NO_SUCH_RULE_ID", "No rule with this ID exists" },
  { 90, "MARPA_ERR_NO_SUCH_SYMBOL_ID", "No symbol with this ID exists" },
  { 91, "MARPA_ERR_BEFORE_FIRST_TREE", "Tree iterator is before first tree" },
  { 92, "MARPA_ERR_SYMBOL_IS_NOT_COMPLETION_EVENT", "Symbol is not set up for completion events" },
  { 93, "MARPA_ERR_SYMBOL_IS_NOT_NULLED_EVENT", "Symbol is not set up for nulled events" },
  { 94, "MARPA_ERR_SYMBOL_IS_NOT_PREDICTION_EVENT", "Symbol is not set up for prediction events" },
  { 95, "MARPA_ERR_RECCE_IS_INCONSISTENT", "MARPA_ERR_RECCE_IS_INCONSISTENT" },
  { 96, "MARPA_ERR_INVALID_ASSERTION_ID", "Assertion ID is malformed" },
  { 97, "MARPA_ERR_NO_SUCH_ASSERTION_ID", "No assertion with this ID exists" },
  { 98, "MARPA_ERR_HEADERS_DO_NOT_MATCH", "Internal error: Libmarpa was built incorrectly" }
}

local _events = {
  { 0, "MARPA_EVENT_NONE", "No event" },
  { 1, "MARPA_EVENT_COUNTED_NULLABLE", "This symbol is a counted nullable" },
  { 2, "MARPA_EVENT_EARLEY_ITEM_THRESHOLD", "Too many Earley items" },
  { 3, "MARPA_EVENT_EXHAUSTED", "Recognizer is exhausted" },
  { 4, "MARPA_EVENT_LOOP_RULES", "Grammar contains a infinite loop" },
  { 5, "MARPA_EVENT_NULLING_TERMINAL", "This symbol is a nulling terminal" },
  { 6, "MARPA_EVENT_SYMBOL_COMPLETED", "Completed symbol" },
  { 7, "MARPA_EVENT_SYMBOL_EXPECTED", "Expecting symbol" },
  { 8, "MARPA_EVENT_SYMBOL_NULLED", "Symbol was nulled" },
  { 9, "MARPA_EVENT_SYMBOL_PREDICTED", "Symbol was predicted" }
}

local _steps = {
  { 0, "MARPA_STEP_INTERNAL1" },
  { 1, "MARPA_STEP_RULE" },
  { 2, "MARPA_STEP_TOKEN" },
  { 3, "MARPA_STEP_NULLING_SYMBOL" },
  { 4, "MARPA_STEP_TRACE" },
  { 5, "MARPA_STEP_INACTIVE" },
  { 6, "MARPA_STEP_INTERNAL2" },
  { 7, "MARPA_STEP_INITIAL" }
}

errors = {}
for index, value in ipairs(_errors) do
  local num   = value[1]
  local const = value[2]
  local desc  = value[3]
  errors[num + 1] = { const, desc }
end

events = {}
for index, value in ipairs(_events) do
  local num   = value[1]
  local const = value[2]
  local desc  = value[3]
  table.insert( events, { const, desc } )
end

steps = {}
for index, value in ipairs(_steps) do
  local num   = value[1]
  local const = value[2]
  local desc  = value[3]
  table.insert( steps, { const, desc } )
end

codes = { errors = errors, events = events, steps = steps }

local jit = require("jit")
assert(jit.version_num >= 20003, jit.version .. " found, at least 2.0.3 required.")

ffi = require("ffi")

ffi.cdef[[
static const int MARPA_MAJOR_VERSION = 7;
static const int MARPA_MINOR_VERSION = 5;
static const int MARPA_MICRO_VERSION = 0;

static const int MARPA_ERR_NONE = 0;
static const int MARPA_ERR_AHFA_IX_NEGATIVE = 1;
static const int MARPA_ERR_AHFA_IX_OOB = 2;
static const int MARPA_ERR_ANDID_NEGATIVE = 3;
static const int MARPA_ERR_ANDID_NOT_IN_OR = 4;
static const int MARPA_ERR_ANDIX_NEGATIVE = 5;
static const int MARPA_ERR_BAD_SEPARATOR = 6;
static const int MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED = 7;
static const int MARPA_ERR_COUNTED_NULLABLE = 8;
static const int MARPA_ERR_DEVELOPMENT = 9;
static const int MARPA_ERR_DUPLICATE_AND_NODE = 10;
static const int MARPA_ERR_DUPLICATE_RULE = 11;
static const int MARPA_ERR_DUPLICATE_TOKEN = 12;
static const int MARPA_ERR_YIM_COUNT = 13;
static const int MARPA_ERR_YIM_ID_INVALID = 14;
static const int MARPA_ERR_EVENT_IX_NEGATIVE = 15;
static const int MARPA_ERR_EVENT_IX_OOB = 16;
static const int MARPA_ERR_GRAMMAR_HAS_CYCLE = 17;
static const int MARPA_ERR_INACCESSIBLE_TOKEN = 18;
static const int MARPA_ERR_INTERNAL = 19;
static const int MARPA_ERR_INVALID_AHFA_ID = 20;
static const int MARPA_ERR_INVALID_AIMID = 21;
static const int MARPA_ERR_INVALID_BOOLEAN = 22;
static const int MARPA_ERR_INVALID_IRLID = 23;
static const int MARPA_ERR_INVALID_NSYID = 24;
static const int MARPA_ERR_INVALID_LOCATION = 25;
static const int MARPA_ERR_INVALID_RULE_ID = 26;
static const int MARPA_ERR_INVALID_START_SYMBOL = 27;
static const int MARPA_ERR_INVALID_SYMBOL_ID = 28;
static const int MARPA_ERR_I_AM_NOT_OK = 29;
static const int MARPA_ERR_MAJOR_VERSION_MISMATCH = 30;
static const int MARPA_ERR_MICRO_VERSION_MISMATCH = 31;
static const int MARPA_ERR_MINOR_VERSION_MISMATCH = 32;
static const int MARPA_ERR_NOOKID_NEGATIVE = 33;
static const int MARPA_ERR_NOT_PRECOMPUTED = 34;
static const int MARPA_ERR_NOT_TRACING_COMPLETION_LINKS = 35;
static const int MARPA_ERR_NOT_TRACING_LEO_LINKS = 36;
static const int MARPA_ERR_NOT_TRACING_TOKEN_LINKS = 37;
static const int MARPA_ERR_NO_AND_NODES = 38;
static const int MARPA_ERR_NO_EARLEY_SET_AT_LOCATION = 39;
static const int MARPA_ERR_NO_OR_NODES = 40;
static const int MARPA_ERR_NO_PARSE = 41;
static const int MARPA_ERR_NO_RULES = 42;
static const int MARPA_ERR_NO_START_SYMBOL = 43;
static const int MARPA_ERR_NO_TOKEN_EXPECTED_HERE = 44;
static const int MARPA_ERR_NO_TRACE_YIM = 45;
static const int MARPA_ERR_NO_TRACE_YS = 46;
static const int MARPA_ERR_NO_TRACE_PIM = 47;
static const int MARPA_ERR_NO_TRACE_SRCL = 48;
static const int MARPA_ERR_NULLING_TERMINAL = 49;
static const int MARPA_ERR_ORDER_FROZEN = 50;
static const int MARPA_ERR_ORID_NEGATIVE = 51;
static const int MARPA_ERR_OR_ALREADY_ORDERED = 52;
static const int MARPA_ERR_PARSE_EXHAUSTED = 53;
static const int MARPA_ERR_PARSE_TOO_LONG = 54;
static const int MARPA_ERR_PIM_IS_NOT_LIM = 55;
static const int MARPA_ERR_POINTER_ARG_NULL = 56;
static const int MARPA_ERR_PRECOMPUTED = 57;
static const int MARPA_ERR_PROGRESS_REPORT_EXHAUSTED = 58;
static const int MARPA_ERR_PROGRESS_REPORT_NOT_STARTED = 59;
static const int MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT = 60;
static const int MARPA_ERR_RECCE_NOT_STARTED = 61;
static const int MARPA_ERR_RECCE_STARTED = 62;
static const int MARPA_ERR_RHS_IX_NEGATIVE = 63;
static const int MARPA_ERR_RHS_IX_OOB = 64;
static const int MARPA_ERR_RHS_TOO_LONG = 65;
static const int MARPA_ERR_SEQUENCE_LHS_NOT_UNIQUE = 66;
static const int MARPA_ERR_SOURCE_TYPE_IS_AMBIGUOUS = 67;
static const int MARPA_ERR_SOURCE_TYPE_IS_COMPLETION = 68;
static const int MARPA_ERR_SOURCE_TYPE_IS_LEO = 69;
static const int MARPA_ERR_SOURCE_TYPE_IS_NONE = 70;
static const int MARPA_ERR_SOURCE_TYPE_IS_TOKEN = 71;
static const int MARPA_ERR_SOURCE_TYPE_IS_UNKNOWN = 72;
static const int MARPA_ERR_START_NOT_LHS = 73;
static const int MARPA_ERR_SYMBOL_VALUED_CONFLICT = 74;
static const int MARPA_ERR_TERMINAL_IS_LOCKED = 75;
static const int MARPA_ERR_TOKEN_IS_NOT_TERMINAL = 76;
static const int MARPA_ERR_TOKEN_LENGTH_LE_ZERO = 77;
static const int MARPA_ERR_TOKEN_TOO_LONG = 78;
static const int MARPA_ERR_TREE_EXHAUSTED = 79;
static const int MARPA_ERR_TREE_PAUSED = 80;
static const int MARPA_ERR_UNEXPECTED_TOKEN_ID = 81;
static const int MARPA_ERR_UNPRODUCTIVE_START = 82;
static const int MARPA_ERR_VALUATOR_INACTIVE = 83;
static const int MARPA_ERR_VALUED_IS_LOCKED = 84;
static const int MARPA_ERR_RANK_TOO_LOW = 85;
static const int MARPA_ERR_RANK_TOO_HIGH = 86;
static const int MARPA_ERR_SYMBOL_IS_NULLING = 87;
static const int MARPA_ERR_SYMBOL_IS_UNUSED = 88;
static const int MARPA_ERR_NO_SUCH_RULE_ID = 89;
static const int MARPA_ERR_NO_SUCH_SYMBOL_ID = 90;
static const int MARPA_ERR_BEFORE_FIRST_TREE = 91;
static const int MARPA_ERR_SYMBOL_IS_NOT_COMPLETION_EVENT = 92;
static const int MARPA_ERR_SYMBOL_IS_NOT_NULLED_EVENT = 93;
static const int MARPA_ERR_SYMBOL_IS_NOT_PREDICTION_EVENT = 94;
static const int MARPA_ERR_RECCE_IS_INCONSISTENT = 95;
static const int MARPA_ERR_INVALID_ASSERTION_ID = 96;
static const int MARPA_ERR_NO_SUCH_ASSERTION_ID = 97;
static const int MARPA_ERR_HEADERS_DO_NOT_MATCH = 98;


static const int MARPA_EVENT_COUNT = 10;
static const int MARPA_EVENT_NONE = 0;
static const int MARPA_EVENT_COUNTED_NULLABLE = 1;
static const int MARPA_EVENT_EARLEY_ITEM_THRESHOLD = 2;
static const int MARPA_EVENT_EXHAUSTED = 3;
static const int MARPA_EVENT_LOOP_RULES = 4;
static const int MARPA_EVENT_NULLING_TERMINAL = 5;
static const int MARPA_EVENT_SYMBOL_COMPLETED = 6;
static const int MARPA_EVENT_SYMBOL_EXPECTED = 7;
static const int MARPA_EVENT_SYMBOL_NULLED = 8;
static const int MARPA_EVENT_SYMBOL_PREDICTED = 9;


static const int MARPA_STEP_COUNT = 8;
static const int MARPA_STEP_INTERNAL1 = 0;
static const int MARPA_STEP_RULE = 1;
static const int MARPA_STEP_TOKEN = 2;
static const int MARPA_STEP_NULLING_SYMBOL = 3;
static const int MARPA_STEP_TRACE = 4;
static const int MARPA_STEP_INACTIVE = 5;
static const int MARPA_STEP_INTERNAL2 = 6;
static const int MARPA_STEP_INITIAL = 7;

/*1339:*/

extern const int marpa_major_version;
extern const int marpa_minor_version;
extern const int marpa_micro_version;

/*109:*/

// #define marpa_g_event_value(event) \
//    ((event)->t_value)
/*:109*//*293:*/

static const int MARPA_KEEP_SEPARATION = 0x1;
/*:293*//*297:*/

static const int MARPA_PROPER_SEPARATION = 0x2;
/*:297*//*1041:*/

// #define marpa_v_step_type(v) ((v)->t_step_type)
// #define marpa_v_token(v) \
//    ((v)->t_token_id)
// #define marpa_v_symbol(v) marpa_v_token(v)
// #define marpa_v_token_value(v) \
//    ((v)->t_token_value)
// #define marpa_v_rule(v) \
//    ((v)->t_rule_id)
// #define marpa_v_arg_0(v) \
//    ((v)->t_arg_0)
// #define marpa_v_arg_n(v) \
//    ((v)->t_arg_n)
// #define marpa_v_result(v) \
//    ((v)->t_result)
// #define marpa_v_rule_start_es_id(v) ((v)->t_rule_start_ys_id)
// #define marpa_v_token_start_es_id(v) ((v)->t_token_start_ys_id)
// #define marpa_v_es_id(v) ((v)->t_ys_id)

/*:1041*/

/*47:*/

struct marpa_g;
struct marpa_avl_table;
typedef struct marpa_g*Marpa_Grammar;
/*:47*//*542:*/

struct marpa_r;
typedef struct marpa_r*Marpa_Recognizer;
typedef Marpa_Recognizer Marpa_Recce;
/*:542*//*924:*/

struct marpa_bocage;
typedef struct marpa_bocage*Marpa_Bocage;
/*:924*//*960:*/

struct marpa_order;
typedef struct marpa_order*Marpa_Order;
/*:960*//*961:*/

typedef Marpa_Order ORDER;
/*:961*//*997:*/

struct marpa_tree;
typedef struct marpa_tree*Marpa_Tree;
/*:997*//*1036:*/

struct marpa_value;
typedef struct marpa_value*Marpa_Value;
/*:1036*/

/*91:*/

typedef int Marpa_Rank;
/*:91*//*108:*/

struct marpa_event;
typedef int Marpa_Event_Type;
/*:108*//*134:*/

typedef int Marpa_Error_Code;
/*:134*//*141:*/

typedef int Marpa_Symbol_ID;
/*:141*//*213:*/

typedef int Marpa_NSY_ID;
/*:213*//*251:*/

typedef int Marpa_Rule_ID;
/*:251*//*325:*/

typedef int Marpa_IRL_ID;
/*:325*//*446:*/

typedef int Marpa_AHM_ID;
/*:446*//*527:*/

typedef int Marpa_Assertion_ID;

/*:527*//*618:*/
typedef int Marpa_Earleme;
/*:618*//*620:*/
typedef int Marpa_Earley_Set_ID;
/*:620*//*643:*/
typedef int Marpa_Earley_Item_ID;
/*:643*//*863:*/

typedef int Marpa_Or_Node_ID;
/*:863*//*917:*/

typedef int Marpa_And_Node_ID;
/*:917*//*1031:*/

typedef int Marpa_Nook_ID;
/*:1031*//*1079:*/

typedef int Marpa_Step_Type;
/*:1079*//*1225:*/

typedef const char*Marpa_Message_ID;

/*:1225*/

/*44:*/

struct marpa_config{
int t_is_ok;
Marpa_Error_Code t_error;
const char*t_error_string;
};
typedef struct marpa_config Marpa_Config;

/*:44*//*110:*/

struct marpa_event{
Marpa_Event_Type t_type;
int t_value;
};
typedef struct marpa_event Marpa_Event;
/*:110*//*817:*/

struct marpa_progress_item{
Marpa_Rule_ID t_rule_id;
int t_position;
int t_origin;
};

/*:817*//*1040:*/

struct marpa_value{
Marpa_Step_Type t_step_type;
Marpa_Symbol_ID t_token_id;
int t_token_value;
Marpa_Rule_ID t_rule_id;
int t_arg_0;
int t_arg_n;
int t_result;
Marpa_Earley_Set_ID t_token_start_ys_id;
Marpa_Earley_Set_ID t_rule_start_ys_id;
Marpa_Earley_Set_ID t_ys_id;
};
/*:1040*/

/*1224:*/

extern void*(*const marpa__out_of_memory)(void);

/*:1224*//*1316:*/

extern int marpa__default_debug_handler(const char*format,...);
extern int(*marpa__debug_handler)(const char*,...);
extern int marpa__debug_level;

/*:1316*/


/*:1339*/

Marpa_Error_Code marpa_check_version (int required_major, int required_minor, int required_micro );
Marpa_Error_Code marpa_version (int* version);
int marpa_c_init ( Marpa_Config* config);
Marpa_Error_Code marpa_c_error ( Marpa_Config* config, const char** p_error_string );
Marpa_Grammar marpa_g_new ( Marpa_Config* configuration );
int marpa_g_force_valued ( Marpa_Grammar g );
Marpa_Grammar marpa_g_ref (Marpa_Grammar g);
void marpa_g_unref (Marpa_Grammar g);
Marpa_Symbol_ID marpa_g_start_symbol (Marpa_Grammar g);
Marpa_Symbol_ID marpa_g_start_symbol_set ( Marpa_Grammar g, Marpa_Symbol_ID sym_id);
int marpa_g_highest_symbol_id (Marpa_Grammar g);
int marpa_g_symbol_is_accessible (Marpa_Grammar g, Marpa_Symbol_ID sym_id);
int marpa_g_symbol_is_completion_event ( Marpa_Grammar g, Marpa_Symbol_ID sym_id);
int marpa_g_symbol_is_completion_event_set ( Marpa_Grammar g, Marpa_Symbol_ID sym_id, int value);
int marpa_g_symbol_is_nulled_event ( Marpa_Grammar g, Marpa_Symbol_ID sym_id);
int marpa_g_symbol_is_nulled_event_set ( Marpa_Grammar g, Marpa_Symbol_ID sym_id, int value);
int marpa_g_symbol_is_nullable ( Marpa_Grammar g, Marpa_Symbol_ID sym_id);
int marpa_g_symbol_is_nulling (Marpa_Grammar g, Marpa_Symbol_ID sym_id);
int marpa_g_symbol_is_productive (Marpa_Grammar g, Marpa_Symbol_ID sym_id);
int marpa_g_symbol_is_prediction_event ( Marpa_Grammar g, Marpa_Symbol_ID sym_id);
int marpa_g_symbol_is_prediction_event_set ( Marpa_Grammar g, Marpa_Symbol_ID sym_id, int value);
int marpa_g_symbol_is_start ( Marpa_Grammar g, Marpa_Symbol_ID sym_id);
int marpa_g_symbol_is_terminal ( Marpa_Grammar g, Marpa_Symbol_ID sym_id);
int marpa_g_symbol_is_terminal_set ( Marpa_Grammar g, Marpa_Symbol_ID sym_id, int value);
Marpa_Symbol_ID marpa_g_symbol_new (Marpa_Grammar g);
int marpa_g_highest_rule_id (Marpa_Grammar g);
int marpa_g_rule_is_accessible (Marpa_Grammar g, Marpa_Rule_ID rule_id);
int marpa_g_rule_is_nullable ( Marpa_Grammar g, Marpa_Rule_ID ruleid);
int marpa_g_rule_is_nulling (Marpa_Grammar g, Marpa_Rule_ID ruleid);
int marpa_g_rule_is_loop (Marpa_Grammar g, Marpa_Rule_ID rule_id);
int marpa_g_rule_is_productive (Marpa_Grammar g, Marpa_Rule_ID rule_id);
int marpa_g_rule_length ( Marpa_Grammar g, Marpa_Rule_ID rule_id);
Marpa_Symbol_ID marpa_g_rule_lhs ( Marpa_Grammar g, Marpa_Rule_ID rule_id);
Marpa_Rule_ID marpa_g_rule_new (Marpa_Grammar g, Marpa_Symbol_ID lhs_id, Marpa_Symbol_ID *rhs_ids, int length);
Marpa_Symbol_ID marpa_g_rule_rhs ( Marpa_Grammar g, Marpa_Rule_ID rule_id, int ix);
int marpa_g_rule_is_proper_separation ( Marpa_Grammar g, Marpa_Rule_ID rule_id);
int marpa_g_sequence_min ( Marpa_Grammar g, Marpa_Rule_ID rule_id);
Marpa_Rule_ID marpa_g_sequence_new (Marpa_Grammar g, Marpa_Symbol_ID lhs_id, Marpa_Symbol_ID rhs_id, Marpa_Symbol_ID separator_id, int min, int flags );
int marpa_g_sequence_separator ( Marpa_Grammar g, Marpa_Rule_ID rule_id);
int marpa_g_symbol_is_counted (Marpa_Grammar g, Marpa_Symbol_ID sym_id);
Marpa_Rank marpa_g_rule_rank ( Marpa_Grammar g, Marpa_Rule_ID rule_id);
Marpa_Rank marpa_g_rule_rank_set ( Marpa_Grammar g, Marpa_Rule_ID rule_id, Marpa_Rank rank);
int marpa_g_rule_null_high ( Marpa_Grammar g, Marpa_Rule_ID rule_id);
int marpa_g_rule_null_high_set ( Marpa_Grammar g, Marpa_Rule_ID rule_id, int flag);
int marpa_g_precompute (Marpa_Grammar g);
int marpa_g_is_precomputed (Marpa_Grammar g);
int marpa_g_has_cycle (Marpa_Grammar g);
Marpa_Recognizer marpa_r_new ( Marpa_Grammar g );
Marpa_Recognizer marpa_r_ref (Marpa_Recognizer r);
void marpa_r_unref (Marpa_Recognizer r);
int marpa_r_start_input (Marpa_Recognizer r);
int marpa_r_alternative (Marpa_Recognizer r, Marpa_Symbol_ID token_id, int value, int length);
Marpa_Earleme marpa_r_earleme_complete (Marpa_Recognizer r);
unsigned int marpa_r_current_earleme (Marpa_Recognizer r);
Marpa_Earleme marpa_r_earleme ( Marpa_Recognizer r, Marpa_Earley_Set_ID set_id);
int marpa_r_earley_set_value ( Marpa_Recognizer r, Marpa_Earley_Set_ID earley_set);
int marpa_r_earley_set_values ( Marpa_Recognizer r, Marpa_Earley_Set_ID earley_set, int* p_value, void** p_pvalue );
unsigned int marpa_r_furthest_earleme (Marpa_Recognizer r);
Marpa_Earley_Set_ID marpa_r_latest_earley_set (Marpa_Recognizer r);
int marpa_r_latest_earley_set_value_set ( Marpa_Recognizer r, int value);
int marpa_r_latest_earley_set_values_set ( Marpa_Recognizer r, int value, void* pvalue);
int marpa_r_earley_item_warning_threshold (Marpa_Recognizer r);
int marpa_r_earley_item_warning_threshold_set (Marpa_Recognizer r, int threshold);
int marpa_r_expected_symbol_event_set ( Marpa_Recognizer r, Marpa_Symbol_ID symbol_id, int value);
int marpa_r_is_exhausted (Marpa_Recognizer r);
int marpa_r_terminals_expected ( Marpa_Recognizer r, Marpa_Symbol_ID* buffer);
int marpa_r_terminal_is_expected ( Marpa_Recognizer r, Marpa_Symbol_ID symbol_id);
int marpa_r_completion_symbol_activate ( Marpa_Recognizer r, Marpa_Symbol_ID sym_id, int reactivate );
int marpa_r_nulled_symbol_activate ( Marpa_Recognizer r, Marpa_Symbol_ID sym_id, int boolean );
int marpa_r_prediction_symbol_activate ( Marpa_Recognizer r, Marpa_Symbol_ID sym_id, int boolean );
int marpa_r_progress_report_reset ( Marpa_Recognizer r);
int marpa_r_progress_report_start ( Marpa_Recognizer r, Marpa_Earley_Set_ID set_id);
int marpa_r_progress_report_finish ( Marpa_Recognizer r );
Marpa_Rule_ID marpa_r_progress_item ( Marpa_Recognizer r, int* position, Marpa_Earley_Set_ID* origin );
Marpa_Bocage marpa_b_new (Marpa_Recognizer r, Marpa_Earley_Set_ID earley_set_ID);
Marpa_Bocage marpa_b_ref (Marpa_Bocage b);
void marpa_b_unref (Marpa_Bocage b);
int marpa_b_ambiguity_metric (Marpa_Bocage b);
int marpa_b_is_null (Marpa_Bocage b);
Marpa_Order marpa_o_new ( Marpa_Bocage b);
Marpa_Order marpa_o_ref ( Marpa_Order o);
void marpa_o_unref ( Marpa_Order o);
int marpa_o_ambiguity_metric (Marpa_Order o);
int marpa_o_is_null (Marpa_Order o);
int marpa_o_high_rank_only_set ( Marpa_Order o, int flag);
int marpa_o_high_rank_only ( Marpa_Order o);
int marpa_o_rank ( Marpa_Order o );
Marpa_Tree marpa_t_new (Marpa_Order o);
Marpa_Tree marpa_t_ref (Marpa_Tree t);
void marpa_t_unref (Marpa_Tree t);
int marpa_t_next ( Marpa_Tree t);
int marpa_t_parse_count ( Marpa_Tree t);
Marpa_Value marpa_v_new ( Marpa_Tree t );
Marpa_Value marpa_v_ref (Marpa_Value v);
void marpa_v_unref ( Marpa_Value v);
Marpa_Step_Type marpa_v_step ( Marpa_Value v);
Marpa_Event_Type marpa_g_event (Marpa_Grammar g, Marpa_Event* event, int ix);
int marpa_g_event_count ( Marpa_Grammar g );
Marpa_Error_Code marpa_g_error ( Marpa_Grammar g, const char** p_error_string);
Marpa_Error_Code marpa_g_error_clear ( Marpa_Grammar g );
Marpa_Rank marpa_g_default_rank ( Marpa_Grammar g);
Marpa_Rank marpa_g_default_rank_set ( Marpa_Grammar g, Marpa_Rank rank);
Marpa_Rank marpa_g_symbol_rank ( Marpa_Grammar g, Marpa_Symbol_ID sym_id);
Marpa_Rank marpa_g_symbol_rank_set ( Marpa_Grammar g, Marpa_Symbol_ID sym_id, Marpa_Rank rank);
Marpa_Assertion_ID marpa_g_zwa_new ( Marpa_Grammar g, int default_value);
int marpa_g_zwa_place ( Marpa_Grammar g, Marpa_Assertion_ID zwaid, Marpa_Rule_ID xrl_id, int rhs_ix);
int marpa_r_zwa_default ( Marpa_Recognizer r, Marpa_Assertion_ID zwaid);
int marpa_r_zwa_default_set ( Marpa_Recognizer r, Marpa_Assertion_ID zwaid, int default_value);
Marpa_Assertion_ID marpa_g_highest_zwa_id ( Marpa_Grammar g );
Marpa_Earleme marpa_r_clean ( Marpa_Recognizer r);
int marpa_g_symbol_is_valued ( Marpa_Grammar g, Marpa_Symbol_ID symbol_id);
int marpa_g_symbol_is_valued_set ( Marpa_Grammar g, Marpa_Symbol_ID symbol_id, int value);
int marpa_v_symbol_is_valued ( Marpa_Value v, Marpa_Symbol_ID sym_id );
int marpa_v_symbol_is_valued_set ( Marpa_Value v, Marpa_Symbol_ID sym_id, int value );
int marpa_v_rule_is_valued ( Marpa_Value v, Marpa_Rule_ID rule_id );
int marpa_v_rule_is_valued_set ( Marpa_Value v, Marpa_Rule_ID rule_id, int value );
int marpa_v_valued_force ( Marpa_Value v);
int _marpa_g_nsy_is_start ( Marpa_Grammar g, Marpa_NSY_ID nsy_id);
int _marpa_g_nsy_is_nulling ( Marpa_Grammar g, Marpa_NSY_ID nsy_id);
int _marpa_g_nsy_is_lhs ( Marpa_Grammar g, Marpa_NSY_ID nsy_id);
Marpa_NSY_ID _marpa_g_xsy_nulling_nsy ( Marpa_Grammar g, Marpa_Symbol_ID symid);
Marpa_NSY_ID _marpa_g_xsy_nsy ( Marpa_Grammar g, Marpa_Symbol_ID symid);
int _marpa_g_nsy_is_semantic ( Marpa_Grammar g, Marpa_NSY_ID nsy_id);
Marpa_Rule_ID _marpa_g_source_xsy ( Marpa_Grammar g, Marpa_NSY_ID nsy_id);
Marpa_Rule_ID _marpa_g_nsy_lhs_xrl ( Marpa_Grammar g, Marpa_NSY_ID nsy_id);
int _marpa_g_nsy_xrl_offset ( Marpa_Grammar g, Marpa_NSY_ID nsy_id );
int _marpa_g_rule_is_keep_separation ( Marpa_Grammar g, Marpa_Rule_ID rule_id);
int _marpa_g_nsy_count ( Marpa_Grammar g);
int _marpa_g_irl_count ( Marpa_Grammar g);
Marpa_Symbol_ID _marpa_g_irl_lhs ( Marpa_Grammar g, Marpa_IRL_ID irl_id);
int _marpa_g_irl_length ( Marpa_Grammar g, Marpa_IRL_ID irl_id);
Marpa_Symbol_ID _marpa_g_irl_rhs ( Marpa_Grammar g, Marpa_IRL_ID irl_id, int ix);
int _marpa_g_rule_is_used (Marpa_Grammar g, Marpa_Rule_ID rule_id);
int _marpa_g_irl_is_virtual_lhs (Marpa_Grammar g, Marpa_IRL_ID irl_id);
int _marpa_g_irl_is_virtual_rhs (Marpa_Grammar g, Marpa_IRL_ID irl_id);
int _marpa_g_virtual_start (Marpa_Grammar g, Marpa_IRL_ID irl_id);
int _marpa_g_virtual_end (Marpa_Grammar g, Marpa_IRL_ID irl_id);
Marpa_Rule_ID _marpa_g_source_xrl (Marpa_Grammar g, Marpa_IRL_ID irl_id);
int _marpa_g_real_symbol_count (Marpa_Grammar g, Marpa_IRL_ID irl_id);
Marpa_Rule_ID _marpa_g_irl_semantic_equivalent (Marpa_Grammar g, Marpa_IRL_ID irl_id);
Marpa_Rank _marpa_g_irl_rank ( Marpa_Grammar g, Marpa_IRL_ID irl_id);
Marpa_Rank _marpa_g_nsy_rank ( Marpa_Grammar g, Marpa_IRL_ID nsy_id);
int _marpa_g_ahm_count (Marpa_Grammar g);
Marpa_Rule_ID _marpa_g_ahm_irl (Marpa_Grammar g, Marpa_AHM_ID item_id);
int _marpa_g_ahm_position (Marpa_Grammar g, Marpa_AHM_ID item_id);
Marpa_Symbol_ID _marpa_g_ahm_postdot (Marpa_Grammar g, Marpa_AHM_ID item_id);
int _marpa_r_is_use_leo (Marpa_Recognizer r);
int _marpa_r_is_use_leo_set ( Marpa_Recognizer r, int value);
Marpa_Earley_Set_ID _marpa_r_trace_earley_set (Marpa_Recognizer r);
int _marpa_r_earley_set_size (Marpa_Recognizer r, Marpa_Earley_Set_ID set_id);
Marpa_Earleme _marpa_r_earley_set_trace (Marpa_Recognizer r, Marpa_Earley_Set_ID set_id);
Marpa_AHM_ID _marpa_r_earley_item_trace (Marpa_Recognizer r, Marpa_Earley_Item_ID item_id);
Marpa_Earley_Set_ID _marpa_r_earley_item_origin (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_leo_predecessor_symbol (Marpa_Recognizer r);
Marpa_Earley_Set_ID _marpa_r_leo_base_origin (Marpa_Recognizer r);
Marpa_AHM_ID _marpa_r_leo_base_state (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_postdot_symbol_trace (Marpa_Recognizer r, Marpa_Symbol_ID symid);
Marpa_Symbol_ID _marpa_r_first_postdot_item_trace (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_next_postdot_item_trace (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_postdot_item_symbol (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_first_token_link_trace (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_next_token_link_trace (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_first_completion_link_trace (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_next_completion_link_trace (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_first_leo_link_trace (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_next_leo_link_trace (Marpa_Recognizer r);
Marpa_AHM_ID _marpa_r_source_predecessor_state (Marpa_Recognizer r);
Marpa_Symbol_ID _marpa_r_source_token (Marpa_Recognizer r, int *value_p);
Marpa_Symbol_ID _marpa_r_source_leo_transition_symbol (Marpa_Recognizer r);
Marpa_Earley_Set_ID _marpa_r_source_middle (Marpa_Recognizer r);
int _marpa_b_and_node_count ( Marpa_Bocage b);
Marpa_Earley_Set_ID _marpa_b_and_node_middle ( Marpa_Bocage b, Marpa_And_Node_ID and_node_id);
int _marpa_b_and_node_parent ( Marpa_Bocage b, Marpa_And_Node_ID and_node_id);
int _marpa_b_and_node_predecessor ( Marpa_Bocage b, Marpa_And_Node_ID and_node_id);
int _marpa_b_and_node_cause ( Marpa_Bocage b, Marpa_And_Node_ID and_node_id);
int _marpa_b_and_node_symbol ( Marpa_Bocage b, Marpa_And_Node_ID and_node_id);
Marpa_Symbol_ID _marpa_b_and_node_token ( Marpa_Bocage b, Marpa_And_Node_ID and_node_id, int* value_p);
Marpa_Or_Node_ID _marpa_b_top_or_node ( Marpa_Bocage b);
int _marpa_b_or_node_set ( Marpa_Bocage b, Marpa_Or_Node_ID or_node_id);
int _marpa_b_or_node_origin ( Marpa_Bocage b, Marpa_Or_Node_ID or_node_id);
Marpa_IRL_ID _marpa_b_or_node_irl ( Marpa_Bocage b, Marpa_Or_Node_ID or_node_id);
int _marpa_b_or_node_position ( Marpa_Bocage b, Marpa_Or_Node_ID or_node_id);
int _marpa_b_or_node_is_whole ( Marpa_Bocage b, Marpa_Or_Node_ID or_node_id);
int _marpa_b_or_node_is_semantic ( Marpa_Bocage b, Marpa_Or_Node_ID or_node_id);
int _marpa_b_or_node_first_and ( Marpa_Bocage b, Marpa_Or_Node_ID or_node_id);
int _marpa_b_or_node_last_and ( Marpa_Bocage b, Marpa_Or_Node_ID or_node_id);
int _marpa_b_or_node_and_count ( Marpa_Bocage b, Marpa_Or_Node_ID or_node_id);
Marpa_And_Node_ID _marpa_o_and_order_get ( Marpa_Order o, Marpa_Or_Node_ID or_node_id, int ix);
int _marpa_o_or_node_and_node_count ( Marpa_Order o, Marpa_Or_Node_ID or_node_id);
int _marpa_o_or_node_and_node_id_by_ix ( Marpa_Order o, Marpa_Or_Node_ID or_node_id, int ix);
int _marpa_t_size ( Marpa_Tree t);
Marpa_Or_Node_ID _marpa_t_nook_or_node ( Marpa_Tree t, Marpa_Nook_ID nook_id);
int _marpa_t_nook_choice ( Marpa_Tree t, Marpa_Nook_ID nook_id );
int _marpa_t_nook_parent ( Marpa_Tree t, Marpa_Nook_ID nook_id );
int _marpa_t_nook_cause_is_ready ( Marpa_Tree t, Marpa_Nook_ID nook_id );
int _marpa_t_nook_predecessor_is_ready ( Marpa_Tree t, Marpa_Nook_ID nook_id );
int _marpa_t_nook_is_cause ( Marpa_Tree t, Marpa_Nook_ID nook_id );
int _marpa_t_nook_is_predecessor ( Marpa_Tree t, Marpa_Nook_ID nook_id );
int _marpa_v_trace ( Marpa_Value v, int flag);
Marpa_Nook_ID _marpa_v_nook ( Marpa_Value v);
const char* _marpa_tag(void);
int marpa_debug_level_set ( int level );
void marpa_debug_handler_set ( int (*debug_handler)(const char*, ...) );
]]

C = ffi.load( ffi.abi("win") and "libmarpa.dll" or "marpa" )

local ver = ffi.new("int [3]")
C.marpa_version(ver)

assert(
  C.marpa_check_version ( ver[0], ver[1], ver[2] ) == C.MARPA_ERR_NONE,
  string.format(
    "libmarpa version %d.%d.%d required, %d.%d.%d found.",
    C.MARPA_MAJOR_VERSION,
    C.MARPA_MINOR_VERSION,
    C.MARPA_MICRO_VERSION,
    ver[0],
    ver[1],
    ver[2]
  )
)

-- external errors codes
-- Ref:
--  https://gist.github.com/pczarn/50edb39b432f974fb6b4
--  http://irclog.perlgeek.de/marpa/2014-12-07#i_9772028
local FAILURE       = 1
local INFORMATION   = 2
local SUCCESS       = 3
local eec = {

-- Always succeed.
  marpa_check_version = { nil, nil, 0 },
  marpa_check_version = { nil, nil, 0 },
  marpa_c_init = { nil, nil, 0 },
  marpa_c_error = { nil, nil, 0 },
  marpa_r_earley_item_warning_threshold = { nil, nil, 0 },
  marpa_r_earley_item_warning_threshold_set = { nil, nil, 0 },
  marpa_r_furthest_earleme = { nil, nil, 0 },
  marpa_r_latest_earley_set = { nil, nil, 0 },
  marpa_r_is_exhausted = { nil, nil, 0 },
  marpa_t_parse_count = { nil, nil, 0 },
  marpa_g_error = { nil, nil, 0 },
  marpa_g_error_clear = { nil, nil, 0 },

  marpa_r_unref = { nil, nil, 0 },
  marpa_b_unref = { nil, nil, 0 },
  marpa_o_unref = { nil, nil, 0 },
  marpa_t_unref = { nil, nil, 0 },
  marpa_v_unref = { nil, nil, 0 },

-- Always succeeds. Returns -1 on undefined value.
  marpa_r_current_earleme = { nil, -1, nil },

-- On success, a non-negative integer. On failure, a negative integer.
-- todo: can that "negative integer" be -1? file a github issue
-- if this error handling approach works
  marpa_g_force_valued = { nil, -1, 0 },

-- A non-negative number on success, -2 on failure.
  marpa_version = { -2, nil, 0 },
  marpa_g_symbol_new = { -2, nil, 0 },
  marpa_g_highest_symbol_id = { -2, nil, 0 },

  marpa_g_highest_rule_id = { -2, nil, 0 },
  marpa_g_rule_new = { -2, nil, 0 },
  marpa_g_rule_length = { -2, nil, 0 },

  marpa_g_sequence_new = { -2, nil, 0 },
  marpa_g_symbol_is_counted = { -2, nil, 0 },
  marpa_g_rule_null_high = { -2, nil, 0 },
  marpa_g_rule_null_high_set = { -2, nil, 0 },
  marpa_g_precompute = { -2, nil, 0 },
    -- an error code of MARPA_ERR_GRAMMAR_HAS_CYCLE leaves the grammar in a functional state
  marpa_g_is_precomputed = { -2, nil, 0 },
  marpa_g_has_cycle = { -2, nil, 0 },

  marpa_r_start_input = { -2, nil, 0 },
  marpa_r_earleme_complete  = { -2, nil, 0 },
    -- an exhausted parse may cause a failure

  marpa_r_earleme = { -2, nil, 0 },
  marpa_r_earley_set_value = { -2, nil, 0 },
  marpa_r_earley_set_values = { -2, nil, 0 },
  marpa_r_latest_earley_set_value_set = { -2, nil, 0 },
  marpa_r_latest_earley_set_values_set = { -2, nil, 0 },

  marpa_r_expected_symbol_event_set = { -2, nil, 0 },
  marpa_r_terminals_expected = { -2, nil, 0 },
  marpa_r_terminal_is_expected = { -2, nil, 0 },

  marpa_r_completion_symbol_activate = { -2, nil, 0 },
  marpa_r_nulled_symbol_activate = { -2, nil, 0 },
  marpa_r_prediction_symbol_activate = { -2, nil, 0 },

  marpa_r_progress_report_reset = { -2, nil, 0 },
  marpa_r_progress_report_start = { -2, nil, 0 },
  marpa_r_progress_report_finish = { -2, nil, 0 },

  marpa_b_ambiguity_metric = { -2, nil, 0 },
  marpa_b_is_null = { -2, nil, 0 },

  marpa_o_ambiguity_metric = { -2, nil, 0 },
  marpa_o_is_null = { -2, nil, 0 },

  marpa_o_high_rank_only_set = { -2, nil, 0 },
  marpa_o_high_rank_only = { -2, nil, 0 },
  marpa_o_rank = { -2, nil, 0 },

  marpa_v_step = { -2, nil, 0 },

  marpa_g_event = { -2, nil, 0 },
  marpa_g_event_count = { -2, nil, 0 },

  marpa_g_symbol_is_valued = { -2, nil, 0 },
  marpa_g_symbol_is_valued_set = { -2, nil, 0 },

  marpa_v_symbol_is_valued = { -2, nil, 0 },
  marpa_v_symbol_is_valued_set = { -2, nil, 0 },

  marpa_v_rule_is_valued = { -2, nil, 0 },
  marpa_v_rule_is_valued_set = { -2, nil, 0 },

  marpa_v_valued_force  = { -2, nil, 0 },
    -- sets the error code to an appropriate value, which will never be MARPA_ERR_NONE)

-- A non-negative number on success, -1 on undefined value, -2 on failure.

  marpa_g_start_symbol = { -2, -1, 0 },
  marpa_g_start_symbol_set = { -2, -1, 0 },
  marpa_g_symbol_is_accessible = { -2, -1, 0 },
  marpa_g_symbol_is_completion_event = { -2, -1, 0 },
  marpa_g_symbol_is_completion_event_set = { -2, -1, 0 },
  marpa_g_symbol_is_nulled_event = { -2, -1, 0 },
  marpa_g_symbol_is_nulled_event_set = { -2, -1, 0 },
  marpa_g_symbol_is_nullable = { -2, -1, 0 },
  marpa_g_symbol_is_nulling = { -2, -1, 0 },
  marpa_g_symbol_is_productive = { -2, -1, 0 },
  marpa_g_symbol_is_prediction_event = { -2, -1, 0 },
  marpa_g_symbol_is_prediction_event_set = { -2, -1, 0 },
  marpa_g_symbol_is_start = { -2, -1, 0 },
  marpa_g_symbol_is_terminal = { -2, -1, 0 },
  marpa_g_symbol_is_terminal_set = { -2, -1, 0 },

  marpa_g_rule_is_accessible = { -2, -1, 0 },
  marpa_g_rule_is_nullable = { -2, -1, 0 },
  marpa_g_rule_is_nulling = { -2, -1, 0 },
  marpa_g_rule_is_loop = { -2, -1, 0 },
  marpa_g_rule_is_productive = { -2, -1, 0 },
  marpa_g_rule_lhs = { -2, -1, 0 },
  marpa_g_rule_rhs = { -2, -1, 0 },

  marpa_g_sequence_min = { -2, -1, 0 },
  marpa_g_rule_is_proper_separation = { -2, -1, 0 },
  marpa_g_sequence_separator = { -2, -1, 0 },

  marpa_r_progress_item = { -2, -1, 0 },

  marpa_t_next = { -2, -1, 0 },

-- A non-negative number on success. Return -2 and set the error code to an appropriate value on failure.

  marpa_g_rule_rank = { -2, nil, 0 },
  marpa_g_rule_rank_set = { -2, nil, 0 },

--[[
      -2, and sets the error code to an appropriate value, which will never be MARPA_ERR_NONE. Note that when the rank is -2, the error code is the only way to distinguish success from failure. The error code can be determined by using the marpa_g_error() call.
]]--

-- NULL on failure.
  -- those are currently checked by assert_result()
  marpa_g_new = { ffi.NULL, nil, nil },
  marpa_g_ref = { ffi.NULL, nil, nil },

  marpa_b_new = { ffi.NULL, nil, nil },
      -- If there is no parse ending at Earley set earley_set_ID, marpa_b_new fails and the error code is set to MARPA_ERR_NO_PARSE.
  marpa_b_ref = { ffi.NULL, nil, nil },

  marpa_r_new = { ffi.NULL, nil, nil },
  marpa_r_ref = { ffi.NULL, nil, nil },

  marpa_o_new = { ffi.NULL, nil, nil },
  marpa_o_ref = { ffi.NULL, nil, nil },

  marpa_t_new = { ffi.NULL, nil, nil },
  marpa_t_ref = { ffi.NULL, nil, nil },

  marpa_v_new = { ffi.NULL, nil, nil },
  marpa_v_ref = { ffi.NULL, nil, nil },

-- Other.

  marpa_r_alternative = { nil, nil, 0 },
    -- Returns MARPA_ERR_NONE on success. On failure, some other error code. Several error codes leave the recognizer in a fully recoverable state.

-- Untested methods
  --[[ The methods of this section are not in the external interface, because they have not been adequately tested. Their fate is uncertain. Users should regard these methods as unsupported. ]]--

  marpa_g_default_rank = { -2, nil, 0 },
  marpa_g_default_rank_set = { -2, nil, 0 },
  marpa_g_symbol_rank = { -2, nil, 0 },
  marpa_g_symbol_rank_set = { -2, nil, 0 },

  marpa_g_zwa_new = { nil, nil, nil },
  marpa_g_zwa_place = { nil, nil, nil },

  marpa_r_zwa_default = { nil, nil, nil },
  marpa_r_zwa_default_set = { nil, nil, nil },
      -- On success, returns previous default value of the assertion.
  marpa_g_highest_zwa_id = { nil, nil, nil },

  marpa_r_clean = { nil, nil, nil },

} -- local eec = {

-- error handling
local function error_msg(func, g)
  local error_code = C.marpa_g_error(g, ffi.NULL)
  return string.format("%s returned %d: %s", func, error_code, table.concat(codes.errors[error_code+1], ': ') )
end

local function assert_result(result, func, g)
  local type = type(result)
  if type == "number" then
    if func == 'marpa_r_earleme_complete' then
      assert( result ~= -2, error_msg(func, g) )
    else
      assert( result >= 0, error_msg(func, g) )
    end
  elseif type == "cdata" then
    assert( result ~= ffi.NULL, error_msg(func, g) )
  end
end

return {
  C = C,
  ffi = ffi,
  assert = assert_result
}
