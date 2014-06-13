using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using libshp;

namespace Reader
{
	class MainClass
	{
		public static void Main(string[] input)
		{
			if (input.Length < 3)
			{
				Console.WriteLine("Usage:\n");
				Console.WriteLine("Provide a source shp file and a palette (.pal).");
				Console.WriteLine("Reader.exe <path/to/shpfile.shp> <path/to/palfile.pal>");
				return;
			}

			var args = input.Skip(1).ToArray();

			if (args[0] == "--png")
				Commands.ConvertSpriteToPng(args);
		}
	}
}
