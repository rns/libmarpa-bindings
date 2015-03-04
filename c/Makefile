test: json.exe
	./json.exe expected.json > got.json
	git diff -w got.json expected.json

FILES=json.c grammar.c recognizer.c valuator.c
json.exe: $(FILES)
	gcc $(FILES) -lmarpa -ojson

