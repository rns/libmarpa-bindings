LIBMARPA_JSON=../libmarpa-json/a.exe
LIBMARPA_JSON_ES=../libmarpa-json-es/json_c_es_id.exe
MARPAX_JSON=../marpax_json/json.exe
TIME="env time -o timings.out --append"

date > timings.out
echo ---------------------------- >> timings.out

for i in 0
do
$TIME --format="JSON::XS      %S %U %e" perl -MJSON::XS -MData::Dumper -E 'local $Data::Dumper::Indent = 0; $/=undef; say Data::Dumper::Dumper(JSON::XS::decode_json(<STDIN>))' < test.in
$TIME --format="libmarpa json %S %U %e" $LIBMARPA_JSON test.in
$TIME --format="maprax json   %S %U %e" $MARPAX_JSON test.in
$TIME --format="json ES_value %S %U %e" $LIBMARPA_JSON_ES test.in
$TIME --format="JSON::PP      %S %U %e" perl -MJSON::PP -MData::Dumper -E 'local $Data::Dumper::Indent = 0; $/=undef; say Data::Dumper::Dumper(JSON::PP::decode_json(<STDIN>))' < test.in
done >timing.log 2>&1


