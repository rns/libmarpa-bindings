test: json.exe
	./json.exe expected.json > got.json
	git diff -w got.json expected.json

C_FILES=json.c sgrammar.c recognizer.c valuator.c lexer.c
H_FILES=sgrammar.h json.h
C_FLAGS= # -std=c99 -pedantic -Wall -Wextra 

json.exe: $(C_FILES) $(H_FILES)
	gcc $(C_FLAGS) $(C_FILES) -lmarpa -ojson

