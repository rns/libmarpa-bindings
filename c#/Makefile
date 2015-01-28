run: json.exe
	json.exe

json.exe : json.cs libmarpa.cs
	vs csc /unsafe /target:exe json.cs libmarpa.cs

clean:
	del json.exe
	
