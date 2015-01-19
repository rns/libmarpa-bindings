time=/usr/bin/time
LUA_PATH="../lua/?.lua;${LUA_PATH}"

date > timings.out
echo "============================================" >> timings.out
echo "ID              SYST  USER  REAL    MAXRES  " >> timings.out
echo "--              ----  ----  ----  ----------" >> timings.out
for i in 0 #1 2
do

$time -o timings.out --append --format="c libmarpa      %S  %U  %e  %M" ./a.out test.in

$time -o timings.out --append --format="perl XS         %S  %U  %e  %M" perl -MJSON::XS -MData::Dumper -E 'local $Data::Dumper::Indent = 0; $/=undef; say Data::Dumper::Dumper(JSON::XS::decode_json(<STDIN>))' < test.in
$time -o timings.out --append --format="pure perl       %S  %U  %e  %M" perl -MJSON::PP -MData::Dumper -E 'local $Data::Dumper::Indent = 0; $/=undef; say Data::Dumper::Dumper(JSON::PP::decode_json(<STDIN>))' < test.in

$time -o timings.out --append --format="lua cjson       %S  %U  %e  %M" lua -e 'json=require "cjson";require "pl.pretty".dump(json.decode(io.stdin:read("*a")))' < test.in
$time -o timings.out --append --format="lua dkjson      %S  %U  %e  %M" lua -e 'json=require "dkjson";o,_,_=json.decode(io.stdin:read("*a"),1,nil);require "pl.pretty".dump(o)' < test.in

$time -o timings.out --append --format="python json     %S  %U  %e  %M" python -c "import sys,json;from pprint import pprint;pprint(json.loads(sys.stdin.read()))" < test.in
$time -o timings.out --append --format="python libmarpa %S  %U  %e  %M" python ../python/json-libmarpa.py test.in

done >/dev/null 2>&1


