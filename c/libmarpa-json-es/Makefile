EXE_FILE=json_c_es_id

test: json.exe
	./$(EXE_FILE).exe expected.json > got.json
	git diff -w got.json expected.json

C_FILES=$(EXE_FILE).c
H_FILES=
C_FLAGS= # -std=c99 -pedantic -Wall -Wextra 

json.exe: $(C_FILES) $(H_FILES)
	gcc $(C_FLAGS) $(C_FILES) -lmarpa -o$(EXE_FILE)

