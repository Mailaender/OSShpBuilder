﻿using System;
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
		public static void Main (string[] args)
		{
			if (args.Length < 3)
			{
				Console.WriteLine("Usage:\n");
				Console.WriteLine("Provide a source shp file and a palette (.pal).");
				Console.WriteLine("Reader.exe <path/to/shpfile.shp> <path/to/palfile.pal>");
				return;
			}

			if (args[0] == "--png")
				Converter.ConvertSpriteToPng(args.Skip(1).ToArray());
		}
	}

	static class Converter
	{
		public static void ConvertSpriteToPng(string[] args)
		{
			var src = args[0];
			var shadowIndex = new int[] { };

			var palette = Palette.Load(args[1], shadowIndex);

			ISpriteSource source;

			using (var stream = File.OpenRead(src))
				if (stream == null)
					return;

			using (var stream = File.OpenRead(src))
				source = SpriteSource.LoadSpriteSource(stream, src);

			// The r8 padding requires external information that we can't access here.
			var usePadding = false; // !(args.Contains("--nopadding") || source is R8Reader);
			var count = 0;
			var prefix = Path.GetFileNameWithoutExtension(src);

			foreach (var frame in source.Frames)
			{
				var frameSize = usePadding ? frame.FrameSize : frame.Size;
				var offset = usePadding ? (frame.Offset - 0.5f * new float2(frame.Size - frame.FrameSize)).ToInt2() : int2.Zero;

				// shp(ts) may define empty frames
				if (frameSize.Width == 0 && frameSize.Height == 0)
				{
					count++;
					continue;
				}

				using (var bitmap = new Bitmap(frameSize.Width, frameSize.Height, PixelFormat.Format8bppIndexed))
				{
					bitmap.Palette = palette.AsSystemPalette();
					var data = bitmap.LockBits(new Rectangle(0, 0, frameSize.Width, frameSize.Height),
						ImageLockMode.WriteOnly, PixelFormat.Format8bppIndexed);

					// Clear the frame
					if (usePadding)
					{
						var clearRow = new byte[data.Stride];
						for (var i = 0; i < frameSize.Height; i++)
							Marshal.Copy(clearRow, 0, new IntPtr(data.Scan0.ToInt64() + i * data.Stride), data.Stride);
					}

					for (var i = 0; i < frame.Size.Height; i++)
					{
						var destIndex = new IntPtr(data.Scan0.ToInt64() + (i + offset.Y) * data.Stride + offset.X);
						Marshal.Copy(frame.Data, i * frame.Size.Width, destIndex, frame.Size.Width);
					}

					bitmap.UnlockBits(data);

					var filename = "{0}-{1:D4}.png".F(prefix, count++);
					bitmap.Save(filename);
				}
			}
			Console.WriteLine("Saved {0}-[0..{1}].png", prefix, count - 1);
		}
	}
}
