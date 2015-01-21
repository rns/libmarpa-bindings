set time=c:\cygwin\bin\time.exe
set output=timings.win.out

date /T >%output%
time /T >>%output%

ver >> %output%

echo ============================================ >> %output%
echo DESCRIPTION     SYST  USER  REAL    MAXRES   >> %output%
echo -----------     ----  ----  ----  ---------- >> %output%

%time% -o %output% --append --format="c libmarpa      %%S  %%U  %%e  %%M" .\a.exe test.in >nul 2>&1

%time% -o %output% --append --format="perl XS         %%S  %%U  %%e  %%M" perl -MJSON::XS -MData::Dumper -E "local $Data::Dumper::Indent = 0; $/=undef; say Data::Dumper::Dumper(JSON::XS::decode_json(<STDIN>))" < test.in >nul 2>&1
%time% -o %output% --append --format="pure perl       %%S  %%U  %%e  %%M" perl -MJSON::PP -MData::Dumper -E "local $Data::Dumper::Indent = 0; $/=undef; say Data::Dumper::Dumper(JSON::PP::decode_json(<STDIN>))" < test.in >nul 2>&1

: %time% -o %output% --append --format="lua cjson       %%S  %%U  %%e  %%M" lua -e 'json=require "cjson";require "pl.pretty".dump(json.decode(io.stdin:read("*a")))' < test.in >nul 2>&1
%time% -o %output% --append --format="luajit dkjson   %%S  %%U  %%e  %%M" luajit -e 'json=require "dkjson";o,_,_=json.decode(io.stdin:read("*a"),1,nil);require "pl.pretty".dump(o)' < test.in >nul 2>&1

%time% -o %output% --append --format="python json     %%S  %%U  %%e  %%M" python -c "import sys,json;from pprint import pprint;pprint(json.loads(sys.stdin.read()))" < test.in >nul 2>&1
: %time% -o %output% --append --format="python libmarpa %%S  %%U  %%e  %%M" python ..\python\json-libmarpa.py test.in >nul 2>&1

%time% -o %output% --append --format="luajit libmarpa %%S  %%U  %%e  %%M" luajit ..\lua\json-libmarpa.lua test.in >nul 2>&1



