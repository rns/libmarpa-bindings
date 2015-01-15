import os
import sys
import cffi
import mmap
import re

from libmarpa import ffi, lib
import libmarpa_codes as codes

ver = ffi.new("int [3]")
lib.marpa_version(ver)

uname = os.uname()
print "os:", uname[0], uname[2], uname[3], uname[4]
print "python version:",    '.'.join(map(str, sys.version_info[0:3]))
print "libmarpa version:",  '.'.join(map(str, ver))
print "cffi version:",      cffi.__version__
print "-" * 19

config = ffi.new("Marpa_Config*")
lib.marpa_c_init(config)

def fail(s, g):
  e = lib.marpa_g_error(g, ffi.new("char**"))
  assert e == lib.MARPA_ERR_NONE, s + ': ' + codes.errors[e]

g = ffi.gc(lib.marpa_g_new(config), lib.marpa_g_unref)
msg = ffi.new("char **")
assert lib.marpa_c_error(config, msg) == lib.MARPA_ERR_NONE, msg

# grammar symbols from RFC 7159
S_begin_array = lib.marpa_g_symbol_new (g)
assert S_begin_array >= 0, fail ("marpa_g_symbol_new", g)
S_begin_object = lib.marpa_g_symbol_new (g)
assert S_begin_object >= 0, fail ("marpa_g_symbol_new", g)
S_end_array = lib.marpa_g_symbol_new (g)
assert S_end_array >= 0, fail ("marpa_g_symbol_new", g)
S_end_object = lib.marpa_g_symbol_new (g)
assert S_end_object >= 0, fail ("marpa_g_symbol_new", g)
S_name_separator = lib.marpa_g_symbol_new (g)
assert S_name_separator >= 0, fail ("marpa_g_symbol_new", g)
S_value_separator = lib.marpa_g_symbol_new (g)
assert S_value_separator >= 0, fail ("marpa_g_symbol_new", g)
S_member = lib.marpa_g_symbol_new (g)
assert S_member >= 0, fail ("marpa_g_symbol_new", g)
S_value = lib.marpa_g_symbol_new (g)
assert S_value >= 0, fail ("marpa_g_symbol_new", g)
S_false = lib.marpa_g_symbol_new (g)
assert S_false >= 0, fail ("marpa_g_symbol_new", g)
S_null = lib.marpa_g_symbol_new (g)
assert S_null >= 0, fail ("marpa_g_symbol_new", g)
S_true = lib.marpa_g_symbol_new (g)
assert S_true >= 0, fail ("marpa_g_symbol_new", g)
S_object = lib.marpa_g_symbol_new (g)
assert S_object >= 0, fail ("marpa_g_symbol_new", g)
S_array = lib.marpa_g_symbol_new (g)
assert S_array >= 0, fail ("marpa_g_symbol_new", g)
S_number = lib.marpa_g_symbol_new (g)
assert S_number >= 0, fail ("marpa_g_symbol_new", g)
S_string = lib.marpa_g_symbol_new (g)
assert S_string >= 0, fail ("marpa_g_symbol_new", g)

# Additional
S_object_contents = lib.marpa_g_symbol_new (g)
assert S_object_contents >= 0, fail ("marpa_g_symbol_new", g)
S_array_contents = lib.marpa_g_symbol_new (g)
assert S_array_contents >= 0, fail ("marpa_g_symbol_new", g)

symbol_name = ['S_start'] * 100
symbol_name[S_begin_array] = 'S_begin_array'
symbol_name[S_begin_object] = 'S_begin_object'
symbol_name[S_end_array] = 'S_end_array'
symbol_name[S_end_object] = 'S_end_object'
symbol_name[S_name_separator] = 'S_name_separator'
symbol_name[S_value_separator] = 'S_value_separator'
symbol_name[S_member] = 'S_member'
symbol_name[S_value] = 'S_value'
symbol_name[S_false] = 'S_false'
symbol_name[S_null] = 'S_null'
symbol_name[S_true] = 'S_true'
symbol_name[S_object] = 'S_object'
symbol_name[S_array] = 'S_array'
symbol_name[S_number] = 'S_number'
symbol_name[S_string] = 'S_string'
symbol_name[S_object_contents] = 'S_object_contents'
symbol_name[S_array_contents] = 'S_array_contents'

rhs = [ 0, 0, 0, 0 ]

rhs[0] = S_false;
assert lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g)
rhs[0] = S_null;
assert lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g)
rhs[0] = S_true;
assert lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g)
rhs[0] = S_object;
assert lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g)
rhs[0] = S_array;
assert lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g)
rhs[0] = S_number;
assert lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g)
rhs[0] = S_string;
assert lib.marpa_g_rule_new (g, S_value, rhs, 1) >= 0, fail ("marpa_g_rule_new", g)

rhs[0] = S_begin_array
rhs[1] = S_array_contents
rhs[2] = S_end_array
assert lib.marpa_g_rule_new (g, S_array, rhs, 3) >= 0, fail ("marpa_g_rule_new", g)

rhs[0] = S_begin_object
rhs[1] = S_object_contents
rhs[2] = S_end_object
assert lib.marpa_g_rule_new (g, S_object, rhs, 3) >= 0, fail ("marpa_g_rule_new", g)

assert lib.marpa_g_sequence_new \
  (g, S_array_contents, S_value, S_value_separator, 0, lib.MARPA_PROPER_SEPARATION) >= 0, \
  fail ("marpa_g_sequence_new", g)
assert lib.marpa_g_sequence_new \
  (g, S_object_contents, S_member, S_value_separator, 0, lib.MARPA_PROPER_SEPARATION) >= 0, \
  fail ("marpa_g_sequence_new", g)

rhs[0] = S_string;
rhs[1] = S_name_separator;
rhs[2] = S_value;
assert lib.marpa_g_rule_new (g, S_member, rhs, 3) >= 0, fail ("marpa_g_rule_new", g)

assert lib.marpa_g_start_symbol_set (g, S_value) >= 0, fail ("marpa_g_start_symbol_set", g)

if lib.marpa_g_precompute (g) < 0:
  e = lib.marpa_g_error (g, ffi.new("char**"))
  print(codes.errors[e])
  sys.exit (1)

r = lib.marpa_r_new (g)

if r == ffi.NULL:
  e = lib.marpa_g_error (g, ffi.new("char**"))
  print(codes.errors[e])
  sys.exit (1)

if not lib.marpa_r_start_input (r) >= 0:
  e = lib.marpa_g_error (g, ffi.new("char**"))
  print(codes.errors[e])
  sys.exit (1)

input = ''
if len(sys.argv) > 1 and os.path.exists(sys.argv[1]):
  with open(sys.argv[1], "rb") as f:
    input = mmap.mmap(f.fileno(), 0)
else:
  input = '[ 1, "abc\ndef", -2.3, null, [], true, false, [1,2,3], {}, {"a":1,"b":2} ]'

print "\nJSON Input:\n", input

# lexing
S_none = -1
token_spec = [
  (r'\{', 'S_begin_object',     S_begin_object),
  (r'\}', 'S_end_object',       S_end_object),
  (r'\[', 'S_begin_array',      S_begin_array),
  (r'\]', 'S_end_array',        S_end_array),
  (r',',  'S_value_separator',  S_value_separator),
  (r':',  'S_name_separator',   S_name_separator),
  
  (r'"(([^"\\]|\\[\\"/bfnrt]|\\u\d{4})*)"',         'S_string', S_string),
  (r'-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?',  'S_number', S_number),
  
  (r'\btrue\b',  'S_true',  S_true),
  (r'\bfalse\b', 'S_false', S_false),
  (r'\bnull\b',  'S_null',  S_null),

  (r'[ \t]+', 'SKIP',     S_none),  # Skip over spaces and tabs
  (r'\n',     'NEWLINE',  S_none),  # Line endings
  (r'.',      'MISMATCH', S_none), # Any other character
]

token_id    = {}
token_regex = []
for triple in token_spec:
  if triple[2] != S_none: 
    token_id[ triple[1] ] = triple[2]
  token_regex.append( '(?P<%s>%s)' % ( triple[1], triple[0] ) )
token_regex = '|'.join(token_regex)

def marpa_g_show_symbols(g):
  highest_symbol_id = lib.marpa_g_highest_symbol_id(g)
  for symbol_id in range(0, highest_symbol_id + 1):
    print "S%s:" % symbol_id, symbol_name[ symbol_id ] 
    
def marpa_g_show_rules(g):
  highest_rule_id = lib.marpa_g_highest_rule_id(g)
  for rule_id in range(0, highest_rule_id + 1):
    lhs_id = lib.marpa_g_rule_lhs(g, rule_id)
    rule_length = lib.marpa_g_rule_length(g, rule_id)
    rhs = []
    for ix in range(0, rule_length):
      rhs.append( symbol_name[ lib.marpa_g_rule_rhs(g, rule_id, ix) ] )
    print "R%s:" % rule_id, symbol_name [ lhs_id ], '::=', ' '.join(rhs)
    sequence_min = lib.marpa_g_sequence_min(g, rule_id)
    if sequence_min != -1:
      is_proper_separation = lib.marpa_g_rule_is_proper_separation(g, rule_id)
      print '    proper separation:', is_proper_separation, 'sequence min:', sequence_min

if 0: marpa_g_show_rules(g)

line_num = 1
line_start = 0
token_values = {}
for mo in re.finditer(token_regex, input):

  token_symbol    = mo.lastgroup
  token_value     = mo.group(token_symbol)
  
  if token_symbol == 'NEWLINE':
      line_start = mo.end()
      line_num += 1
  elif token_symbol == 'SKIP':
      pass
  elif token_symbol == 'MISMATCH':
      raise RuntimeError('%r unexpected on line %d' % (value, line_num))
  else:
      column = mo.start() - line_start
      
      token_symbol_id = token_id[token_symbol]
      token_start     = mo.start()
      token_length    = len(token_value)

#     print token_symbol, token_symbol_id, "'%s'" % token_value, "%s:%s" % (token_start, token_length), '@%s:%s' % (line_num, column)
      
      status = lib.marpa_r_alternative (r, token_symbol_id, token_start + 1, 1)
      if status != lib.MARPA_ERR_NONE:
        expected = ffi.new("Marpa_Symbol_ID*")
        count_of_expected = lib.marpa_r_terminals_expected (r, expected)
        # todo: list expected terminals
        print('marpa_r_alternative: ' + ', '.join(codes.errors[status]))
        sys.exit (1)
      
      status = lib.marpa_r_earleme_complete (r)
      if status < 0:
        e = lib.marpa_g_error (g, ffi.new("char**"))
        print ('marpa_r_earleme_complete:' + e)
        sys.exit (1)
      
      token_values[token_start] = token_value

# valuate
      
bocage = lib.marpa_b_new (r, -1)
if bocage == ffi.NULL:
  e = lib.marpa_g_error (g, ffi.new("char**"))
  print(codes.errors[e])
  sys.exit (1)

order = lib.marpa_o_new (bocage)
if order == ffi.NULL:
  e = lib.marpa_g_error (g, ffi.new("char**"))
  print(codes.errors[e])
  sys.exit (1)

tree = lib.marpa_t_new (order)
if tree == ffi.NULL:
  e = lib.marpa_g_error (g, ffi.new("char**"))
  print(codes.errors[e])
  sys.exit (1)

tree_status = lib.marpa_t_next (tree)
if tree_status <= -1:
  e = lib.marpa_g_error (g, ffi.new("char**"))
  print("marpa_t_next returned:", e, codes.errors[e])
  sys.exit (1)

value = lib.marpa_v_new (tree)
if value == ffi.NULL:
  e = lib.marpa_g_error (g, ffi.new("char**"))
  print("marpa_v_new returned:", e, codes.errors[e])
  sys.exit (1)

column = 0

print "Parser Output:"

while 1:
  step_type = lib.marpa_v_step (value)
  if step_type < 0:
    e = lib.marpa_g_error (g, ffi.new("char**"))
    print("marpa_v_event returned:", e, codes.errors[e])
    sys.exit (1)
  if step_type == lib.MARPA_STEP_INACTIVE:
    if 0: print ("No more events\n")
    break
  if step_type != lib.MARPA_STEP_TOKEN:
    continue
  token = value.t_token_id
  if column > 60:
    sys.stdout.write ("\n")
    column = 0
  if token == S_begin_array:
    sys.stdout.write ('[')
    column += 1
    continue
  if token == S_end_array:
    sys.stdout.write (']')
    column += 1
    continue
  if token == S_begin_object:
    sys.stdout.write ('{')
    column += 1
    continue
  if token == S_end_object:
    sys.stdout.write ('}')
    column += 1
    continue
  if token == S_name_separator:
    sys.stdout.write (':')
    column += 1
    continue
  if token == S_value_separator:
    sys.stdout.write (',')
    column += 1
    continue
  if token == S_null:
    sys.stdout.write( "null" )
    column += 4
    continue
  if token == S_true:
    sys.stdout.write ('true')
    column += 1
    continue
  if token == S_false:
    sys.stdout.write ('false')
    column += 1
    continue
  if token == S_number:
    start_of_number = value.t_token_value - 1
    sys.stdout.write( token_values[start_of_number] )
    column += 1
  if token == S_string:
    start_of_string = value.t_token_value - 1
    sys.stdout.write( token_values[start_of_string] )
    
sys.stdout.write("\n")

