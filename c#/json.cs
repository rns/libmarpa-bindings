using System;
using System.Diagnostics;

using lib = Marpa.libmarpa;

public class json
{
  public static void Main(){
    lib lib;
    try { lib = new lib(); }
    catch(lib.MarpaException e){ Console.WriteLine(e); }

    int[] ver = new int[3];
    lib.marpa_version(ver);

    Console.WriteLine("libmarpa version: " +
      string.Join(".", Array.ConvertAll(ver, x => x.ToString()))
    );
  }
}
