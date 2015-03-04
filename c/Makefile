test: json.exe
	./json.exe expected.json > got.json
	git diff -w got.json expected.json

C_FILES=json.c grammar.c recognizer.c valuator.c grammar.h recognizer.h valuator.h
C_FLAGS= # -std=c99 -pedantic -Wall -Wextra 

json.exe: $(C_FILES)
	gcc $(C_FLAGS) $(C_FILES) -lmarpa -ojson

