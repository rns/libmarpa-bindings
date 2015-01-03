"""
	Python cffi binding to libmarpa
	Prerequisites:
		libmarpa -- https://github.com/jeffreykegler/libmarpa -- built as a shared library
		Python 2.7.8 or later --
		cffi (pip install cffi)
		
	This file is based on marpa_cffi.py by koo5
	-- https://github.com/koo5/new_shit/tree/master/marpa_cffi.
	Here is the copyright notice from that file.

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
"""
from __future__ import absolute_import

from cffi import FFI

ffi = FFI()

ffi.cdef(
"""
//made from marpa.h with version 7.2.0 (Marpa--R2 2.099_000)
//just a few mechanical changes were needed to make cffi happy, 
//i did them by hand for now, but be super careful with different
//versions of marpa
/*
 * 
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

/*
 * DO NOT EDIT DIRECTLY
 * This file is written by the Marpa build process
 * It is not intended to be modified directly
 */

#define MARPA_MAJOR_VERSION ...
#define MARPA_MINOR_VERSION ...
#define MARPA_MICRO_VERSION ...

#define MARPA_ERROR_COUNT ...
#define MARPA_ERR_NONE ...
#define MARPA_ERR_AHFA_IX_NEGATIVE ...
#define MARPA_ERR_AHFA_IX_OOB ...
#define MARPA_ERR_ANDID_NEGATIVE ...
#define MARPA_ERR_ANDID_NOT_IN_OR ...
#define MARPA_ERR_ANDIX_NEGATIVE ...
#define MARPA_ERR_BAD_SEPARATOR ...
#define MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED ...
#define MARPA_ERR_COUNTED_NULLABLE ...
#define MARPA_ERR_DEVELOPMENT ...
#define MARPA_ERR_DUPLICATE_AND_NODE ...
#define MARPA_ERR_DUPLICATE_RULE ...
#define MARPA_ERR_DUPLICATE_TOKEN ...
#define MARPA_ERR_YIM_COUNT ...
#define MARPA_ERR_YIM_ID_INVALID ...
#define MARPA_ERR_EVENT_IX_NEGATIVE ...
#define MARPA_ERR_EVENT_IX_OOB ...
#define MARPA_ERR_GRAMMAR_HAS_CYCLE ...
#define MARPA_ERR_INACCESSIBLE_TOKEN ...
#define MARPA_ERR_INTERNAL ...
#define MARPA_ERR_INVALID_AHFA_ID ...
#define MARPA_ERR_INVALID_AIMID ...
#define MARPA_ERR_INVALID_BOOLEAN ...
#define MARPA_ERR_INVALID_IRLID ...
#define MARPA_ERR_INVALID_NSYID ...
#define MARPA_ERR_INVALID_LOCATION ...
#define MARPA_ERR_INVALID_RULE_ID ...
#define MARPA_ERR_INVALID_START_SYMBOL ...
#define MARPA_ERR_INVALID_SYMBOL_ID ...
#define MARPA_ERR_I_AM_NOT_OK ...
#define MARPA_ERR_MAJOR_VERSION_MISMATCH ...
#define MARPA_ERR_MICRO_VERSION_MISMATCH ...
#define MARPA_ERR_MINOR_VERSION_MISMATCH ...
#define MARPA_ERR_NOOKID_NEGATIVE ...
#define MARPA_ERR_NOT_PRECOMPUTED ...
#define MARPA_ERR_NOT_TRACING_COMPLETION_LINKS ...
#define MARPA_ERR_NOT_TRACING_LEO_LINKS ...
#define MARPA_ERR_NOT_TRACING_TOKEN_LINKS ...
#define MARPA_ERR_NO_AND_NODES ...
#define MARPA_ERR_NO_EARLEY_SET_AT_LOCATION ...
#define MARPA_ERR_NO_OR_NODES ...
#define MARPA_ERR_NO_PARSE ...
#define MARPA_ERR_NO_RULES ...
#define MARPA_ERR_NO_START_SYMBOL ...
#define MARPA_ERR_NO_TOKEN_EXPECTED_HERE ...
#define MARPA_ERR_NO_TRACE_YIM ...
#define MARPA_ERR_NO_TRACE_YS ...
#define MARPA_ERR_NO_TRACE_PIM ...
#define MARPA_ERR_NO_TRACE_SRCL ...
#define MARPA_ERR_NULLING_TERMINAL ...
#define MARPA_ERR_ORDER_FROZEN ...
#define MARPA_ERR_ORID_NEGATIVE ...
#define MARPA_ERR_OR_ALREADY_ORDERED ...
#define MARPA_ERR_PARSE_EXHAUSTED ...
#define MARPA_ERR_PARSE_TOO_LONG ...
#define MARPA_ERR_PIM_IS_NOT_LIM ...
#define MARPA_ERR_POINTER_ARG_NULL ...
#define MARPA_ERR_PRECOMPUTED ...
#define MARPA_ERR_PROGRESS_REPORT_EXHAUSTED ...
#define MARPA_ERR_PROGRESS_REPORT_NOT_STARTED ...
#define MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT ...
#define MARPA_ERR_RECCE_NOT_STARTED ...
#define MARPA_ERR_RECCE_STARTED ...
#define MARPA_ERR_RHS_IX_NEGATIVE ...
#define MARPA_ERR_RHS_IX_OOB ...
#define MARPA_ERR_RHS_TOO_LONG ...
#define MARPA_ERR_SEQUENCE_LHS_NOT_UNIQUE ...
#define MARPA_ERR_SOURCE_TYPE_IS_AMBIGUOUS ...
#define MARPA_ERR_SOURCE_TYPE_IS_COMPLETION ...
#define MARPA_ERR_SOURCE_TYPE_IS_LEO ...
#define MARPA_ERR_SOURCE_TYPE_IS_NONE ...
#define MARPA_ERR_SOURCE_TYPE_IS_TOKEN ...
#define MARPA_ERR_SOURCE_TYPE_IS_UNKNOWN ...
#define MARPA_ERR_START_NOT_LHS ...
#define MARPA_ERR_SYMBOL_VALUED_CONFLICT ...
#define MARPA_ERR_TERMINAL_IS_LOCKED ...
#define MARPA_ERR_TOKEN_IS_NOT_TERMINAL ...
#define MARPA_ERR_TOKEN_LENGTH_LE_ZERO ...
#define MARPA_ERR_TOKEN_TOO_LONG ...
#define MARPA_ERR_TREE_EXHAUSTED ...
#define MARPA_ERR_TREE_PAUSED ...
#define MARPA_ERR_UNEXPECTED_TOKEN_ID ...
#define MARPA_ERR_UNPRODUCTIVE_START ...
#define MARPA_ERR_VALUATOR_INACTIVE ...
#define MARPA_ERR_VALUED_IS_LOCKED ...
#define MARPA_ERR_RANK_TOO_LOW ...
#define MARPA_ERR_RANK_TOO_HIGH ...
#define MARPA_ERR_SYMBOL_IS_NULLING ...
#define MARPA_ERR_SYMBOL_IS_UNUSED ...
#define MARPA_ERR_NO_SUCH_RULE_ID ...
#define MARPA_ERR_NO_SUCH_SYMBOL_ID ...
#define MARPA_ERR_BEFORE_FIRST_TREE ...
#define MARPA_ERR_SYMBOL_IS_NOT_COMPLETION_EVENT ...
#define MARPA_ERR_SYMBOL_IS_NOT_NULLED_EVENT ...
#define MARPA_ERR_SYMBOL_IS_NOT_PREDICTION_EVENT ...
#define MARPA_ERR_RECCE_IS_INCONSISTENT ...
#define MARPA_ERR_INVALID_ASSERTION_ID ...
#define MARPA_ERR_NO_SUCH_ASSERTION_ID ...
#define MARPA_ERR_HEADERS_DO_NOT_MATCH ...


#define MARPA_EVENT_COUNT ...
#define MARPA_EVENT_NONE ...
#define MARPA_EVENT_COUNTED_NULLABLE ...
#define MARPA_EVENT_EARLEY_ITEM_THRESHOLD ...
#define MARPA_EVENT_EXHAUSTED ...
#define MARPA_EVENT_LOOP_RULES ...
#define MARPA_EVENT_NULLING_TERMINAL ...
#define MARPA_EVENT_SYMBOL_COMPLETED ...
#define MARPA_EVENT_SYMBOL_EXPECTED ...
#define MARPA_EVENT_SYMBOL_NULLED ...
#define MARPA_EVENT_SYMBOL_PREDICTED ...


#define MARPA_STEP_COUNT ...
#define MARPA_STEP_INTERNAL1 ...
#define MARPA_STEP_RULE ...
#define MARPA_STEP_TOKEN ...
#define MARPA_STEP_NULLING_SYMBOL ...
#define MARPA_STEP_TRACE ...
#define MARPA_STEP_INACTIVE ...
#define MARPA_STEP_INTERNAL2 ...
#define MARPA_STEP_INITIAL ...

extern const int marpa_major_version;
extern const int marpa_minor_version;
extern const int marpa_micro_version;

#define MARPA_KEEP_SEPARATION  ...

#define MARPA_PROPER_SEPARATION  ...

struct marpa_g;
struct marpa_avl_table;
typedef struct marpa_g*Marpa_Grammar;

struct marpa_r;
typedef struct marpa_r*Marpa_Recognizer;
typedef Marpa_Recognizer Marpa_Recce;

struct marpa_bocage;
typedef struct marpa_bocage*Marpa_Bocage;

struct marpa_order;
typedef struct marpa_order*Marpa_Order;

typedef Marpa_Order ORDER;

struct marpa_tree;
typedef struct marpa_tree*Marpa_Tree;

struct marpa_value;
typedef struct marpa_value*Marpa_Value;

typedef int Marpa_Rank;

struct marpa_event;
typedef int Marpa_Event_Type;

typedef int Marpa_Error_Code;

typedef int Marpa_Symbol_ID;

typedef int Marpa_NSY_ID;

typedef int Marpa_Rule_ID;

typedef int Marpa_IRL_ID;

typedef int Marpa_AHM_ID;

typedef int Marpa_Assertion_ID;

typedef int Marpa_Earleme;
typedef int Marpa_Earley_Set_ID;
typedef int Marpa_Earley_Item_ID;

typedef int Marpa_Or_Node_ID;

typedef int Marpa_And_Node_ID;

typedef int Marpa_Nook_ID;

typedef int Marpa_Step_Type;

typedef const char*Marpa_Message_ID;


struct marpa_config{
int t_is_ok;
Marpa_Error_Code t_error;
const char*t_error_string;
};
typedef struct marpa_config Marpa_Config;


struct marpa_event{
Marpa_Event_Type t_type;
int t_value;
};
typedef struct marpa_event Marpa_Event;

struct marpa_progress_item{
Marpa_Rule_ID t_rule_id;
int t_position;
int t_origin;
};


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

extern void*(*const marpa__out_of_memory)(void);


extern int marpa__default_debug_handler(const char*format,...);
extern int(*marpa__debug_handler)(const char*,...);
extern int marpa__debug_level;


Marpa_Error_Code marpa_check_version (int required_major, int required_minor, int required_micro );

Marpa_Error_Code marpa_version (int version[3]);
//this originally was int * version..
///but this change doesnt seem to make any difference
//in cffi's type checking anyway

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
"""
) # cdef

lib = ffi.verify("""
#include <marpa.h>
""", libraries=['marpa'])

assert lib.MARPA_MAJOR_VERSION == lib.marpa_major_version
assert lib.MARPA_MINOR_VERSION == lib.marpa_minor_version
assert lib.MARPA_MICRO_VERSION == lib.marpa_micro_version
#ver = ffi.new("int [3]")
#lib.marpa_version(ver)

assert lib.marpa_check_version (lib.MARPA_MAJOR_VERSION ,lib.MARPA_MINOR_VERSION, lib.MARPA_MICRO_VERSION ) == lib.MARPA_ERR_NONE
