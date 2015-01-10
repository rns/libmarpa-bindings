using System;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace Marpa {

  public class libmarpa {
    // versions
    public const int MARPA_MAJOR_VERSION = 7;
    public const int MARPA_MINOR_VERSION = 5;
    public const int MARPA_MICRO_VERSION = 0;
    // errors
    public const int MARPA_ERR_NONE = 0;
    public const int MARPA_ERR_AHFA_IX_NEGATIVE = 1;
    public const int MARPA_ERR_AHFA_IX_OOB = 2;
    public const int MARPA_ERR_ANDID_NEGATIVE = 3;
    public const int MARPA_ERR_ANDID_NOT_IN_OR = 4;
    public const int MARPA_ERR_ANDIX_NEGATIVE = 5;
    public const int MARPA_ERR_BAD_SEPARATOR = 6;
    public const int MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED = 7;
    public const int MARPA_ERR_COUNTED_NULLABLE = 8;
    public const int MARPA_ERR_DEVELOPMENT = 9;
    public const int MARPA_ERR_DUPLICATE_AND_NODE = 10;
    public const int MARPA_ERR_DUPLICATE_RULE = 11;
    public const int MARPA_ERR_DUPLICATE_TOKEN = 12;
    public const int MARPA_ERR_YIM_COUNT = 13;
    public const int MARPA_ERR_YIM_ID_INVALID = 14;
    public const int MARPA_ERR_EVENT_IX_NEGATIVE = 15;
    public const int MARPA_ERR_EVENT_IX_OOB = 16;
    public const int MARPA_ERR_GRAMMAR_HAS_CYCLE = 17;
    public const int MARPA_ERR_INACCESSIBLE_TOKEN = 18;
    public const int MARPA_ERR_INTERNAL = 19;
    public const int MARPA_ERR_INVALID_AHFA_ID = 20;
    public const int MARPA_ERR_INVALID_AIMID = 21;
    public const int MARPA_ERR_INVALID_BOOLEAN = 22;
    public const int MARPA_ERR_INVALID_IRLID = 23;
    public const int MARPA_ERR_INVALID_NSYID = 24;
    public const int MARPA_ERR_INVALID_LOCATION = 25;
    public const int MARPA_ERR_INVALID_RULE_ID = 26;
    public const int MARPA_ERR_INVALID_START_SYMBOL = 27;
    public const int MARPA_ERR_INVALID_SYMBOL_ID = 28;
    public const int MARPA_ERR_I_AM_NOT_OK = 29;
    public const int MARPA_ERR_MAJOR_VERSION_MISMATCH = 30;
    public const int MARPA_ERR_MICRO_VERSION_MISMATCH = 31;
    public const int MARPA_ERR_MINOR_VERSION_MISMATCH = 32;
    public const int MARPA_ERR_NOOKID_NEGATIVE = 33;
    public const int MARPA_ERR_NOT_PRECOMPUTED = 34;
    public const int MARPA_ERR_NOT_TRACING_COMPLETION_LINKS = 35;
    public const int MARPA_ERR_NOT_TRACING_LEO_LINKS = 36;
    public const int MARPA_ERR_NOT_TRACING_TOKEN_LINKS = 37;
    public const int MARPA_ERR_NO_AND_NODES = 38;
    public const int MARPA_ERR_NO_EARLEY_SET_AT_LOCATION = 39;
    public const int MARPA_ERR_NO_OR_NODES = 40;
    public const int MARPA_ERR_NO_PARSE = 41;
    public const int MARPA_ERR_NO_RULES = 42;
    public const int MARPA_ERR_NO_START_SYMBOL = 43;
    public const int MARPA_ERR_NO_TOKEN_EXPECTED_HERE = 44;
    public const int MARPA_ERR_NO_TRACE_YIM = 45;
    public const int MARPA_ERR_NO_TRACE_YS = 46;
    public const int MARPA_ERR_NO_TRACE_PIM = 47;
    public const int MARPA_ERR_NO_TRACE_SRCL = 48;
    public const int MARPA_ERR_NULLING_TERMINAL = 49;
    public const int MARPA_ERR_ORDER_FROZEN = 50;
    public const int MARPA_ERR_ORID_NEGATIVE = 51;
    public const int MARPA_ERR_OR_ALREADY_ORDERED = 52;
    public const int MARPA_ERR_PARSE_EXHAUSTED = 53;
    public const int MARPA_ERR_PARSE_TOO_LONG = 54;
    public const int MARPA_ERR_PIM_IS_NOT_LIM = 55;
    public const int MARPA_ERR_POINTER_ARG_NULL = 56;
    public const int MARPA_ERR_PRECOMPUTED = 57;
    public const int MARPA_ERR_PROGRESS_REPORT_EXHAUSTED = 58;
    public const int MARPA_ERR_PROGRESS_REPORT_NOT_STARTED = 59;
    public const int MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT = 60;
    public const int MARPA_ERR_RECCE_NOT_STARTED = 61;
    public const int MARPA_ERR_RECCE_STARTED = 62;
    public const int MARPA_ERR_RHS_IX_NEGATIVE = 63;
    public const int MARPA_ERR_RHS_IX_OOB = 64;
    public const int MARPA_ERR_RHS_TOO_LONG = 65;
    public const int MARPA_ERR_SEQUENCE_LHS_NOT_UNIQUE = 66;
    public const int MARPA_ERR_SOURCE_TYPE_IS_AMBIGUOUS = 67;
    public const int MARPA_ERR_SOURCE_TYPE_IS_COMPLETION = 68;
    public const int MARPA_ERR_SOURCE_TYPE_IS_LEO = 69;
    public const int MARPA_ERR_SOURCE_TYPE_IS_NONE = 70;
    public const int MARPA_ERR_SOURCE_TYPE_IS_TOKEN = 71;
    public const int MARPA_ERR_SOURCE_TYPE_IS_UNKNOWN = 72;
    public const int MARPA_ERR_START_NOT_LHS = 73;
    public const int MARPA_ERR_SYMBOL_VALUED_CONFLICT = 74;
    public const int MARPA_ERR_TERMINAL_IS_LOCKED = 75;
    public const int MARPA_ERR_TOKEN_IS_NOT_TERMINAL = 76;
    public const int MARPA_ERR_TOKEN_LENGTH_LE_ZERO = 77;
    public const int MARPA_ERR_TOKEN_TOO_LONG = 78;
    public const int MARPA_ERR_TREE_EXHAUSTED = 79;
    public const int MARPA_ERR_TREE_PAUSED = 80;
    public const int MARPA_ERR_UNEXPECTED_TOKEN_ID = 81;
    public const int MARPA_ERR_UNPRODUCTIVE_START = 82;
    public const int MARPA_ERR_VALUATOR_INACTIVE = 83;
    public const int MARPA_ERR_VALUED_IS_LOCKED = 84;
    public const int MARPA_ERR_RANK_TOO_LOW = 85;
    public const int MARPA_ERR_RANK_TOO_HIGH = 86;
    public const int MARPA_ERR_SYMBOL_IS_NULLING = 87;
    public const int MARPA_ERR_SYMBOL_IS_UNUSED = 88;
    public const int MARPA_ERR_NO_SUCH_RULE_ID = 89;
    public const int MARPA_ERR_NO_SUCH_SYMBOL_ID = 90;
    public const int MARPA_ERR_BEFORE_FIRST_TREE = 91;
    public const int MARPA_ERR_SYMBOL_IS_NOT_COMPLETION_EVENT = 92;
    public const int MARPA_ERR_SYMBOL_IS_NOT_NULLED_EVENT = 93;
    public const int MARPA_ERR_SYMBOL_IS_NOT_PREDICTION_EVENT = 94;
    public const int MARPA_ERR_RECCE_IS_INCONSISTENT = 95;
    public const int MARPA_ERR_INVALID_ASSERTION_ID = 96;
    public const int MARPA_ERR_NO_SUCH_ASSERTION_ID = 97;
    public const int MARPA_ERR_HEADERS_DO_NOT_MATCH = 98;

    // events
    public const int MARPA_EVENT_COUNT = 10;
    public const int MARPA_EVENT_NONE = 0;
    public const int MARPA_EVENT_COUNTED_NULLABLE = 1;
    public const int MARPA_EVENT_EARLEY_ITEM_THRESHOLD = 2;
    public const int MARPA_EVENT_EXHAUSTED = 3;
    public const int MARPA_EVENT_LOOP_RULES = 4;
    public const int MARPA_EVENT_NULLING_TERMINAL = 5;
    public const int MARPA_EVENT_SYMBOL_COMPLETED = 6;
    public const int MARPA_EVENT_SYMBOL_EXPECTED = 7;
    public const int MARPA_EVENT_SYMBOL_NULLED = 8;
    public const int MARPA_EVENT_SYMBOL_PREDICTED = 9;

    // steps
    public const int MARPA_STEP_COUNT = 8;
    public const int MARPA_STEP_INTERNAL1 = 0;
    public const int MARPA_STEP_RULE = 1;
    public const int MARPA_STEP_TOKEN = 2;
    public const int MARPA_STEP_NULLING_SYMBOL = 3;
    public const int MARPA_STEP_TRACE = 4;
    public const int MARPA_STEP_INACTIVE = 5;
    public const int MARPA_STEP_INTERNAL2 = 6;
    public const int MARPA_STEP_INITIAL = 7;

    [DllImport("libmarpa.dll")]
    public extern static unsafe int marpa_version (int[] version);
    [DllImport("libmarpa.dll")]
    public extern static int marpa_check_version (int required_major, int required_minor, int required_micro);

    public class MarpaException: Exception
    {
        public MarpaException()
        {
        }

        public MarpaException(string message)
            : base(message)
        {
        }

        public MarpaException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }

    public static int[] ver = new int[3];
    static libmarpa() {
      int rc;

      rc = marpa_version(ver);
      if ( rc != MARPA_ERR_NONE ){
        throw new MarpaException("marpa_version returned: " + rc);
      }

      rc = marpa_check_version(MARPA_MAJOR_VERSION, MARPA_MINOR_VERSION, MARPA_MICRO_VERSION);
      if ( rc != MARPA_ERR_NONE ){
        throw new MarpaException(
          String.Format( "libmarpa version mismatch: version {0}.{1}.{2} required, version {3}.{4}.{5} found.",
          MARPA_MAJOR_VERSION, MARPA_MINOR_VERSION, MARPA_MICRO_VERSION,
          ver[0], ver[1], ver[2]
          )
        );
      }
    } // static libmarpa()

  } // public class libmarpa
} // namespace Marpa
