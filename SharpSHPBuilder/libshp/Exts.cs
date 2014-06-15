using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

namespace libshp
{
	public static class Exts
	{
		public static string F(this string str, params object[] objs) { return string.Format(str, objs); }

		public static Lazy<T> Lazy<T>(Func<T> p) { return new Lazy<T>(p); }

		public static Rectangle Bounds(this Bitmap b) { return new Rectangle(0, 0, b.Width, b.Height); }

		public static byte[] ToBytes(this Bitmap bitmap)
		{
			var data = bitmap.LockBits(new Rectangle(0, 0, bitmap.Width, bitmap.Height), ImageLockMode.ReadOnly,
				PixelFormat.Format8bppIndexed);

			var bytes = new byte[bitmap.Width * bitmap.Height];
			for (var i = 0; i < bitmap.Height; i++)
				Marshal.Copy(new IntPtr(data.Scan0.ToInt64() + i * data.Stride),
					bytes, i * bitmap.Width, bitmap.Width);

			bitmap.UnlockBits(data);

			return bytes;
		}
	}

	public static class StreamExts
	{
		public static byte[] ReadBytes(this Stream s, int count)
		{
			if (count < 0)
				throw new ArgumentOutOfRangeException("count", "Non-negative number required.");
			var buffer = new byte[count];
			s.ReadBytes(buffer, 0, count);
			return buffer;
		}

		public static void ReadBytes(this Stream s, byte[] buffer, int offset, int count)
		{
			while (count > 0)
			{
				int bytesRead;
				if ((bytesRead = s.Read(buffer, offset, count)) == 0)
					throw new EndOfStreamException();
				offset += bytesRead;
				count -= bytesRead;
			}
		}

		public static int Peek(this Stream s)
		{
			var b = s.ReadByte();
			if (b == -1)
				return -1;
			s.Seek(-1, SeekOrigin.Current);
			return (byte)b;
		}

		public static byte ReadUInt8(this Stream s)
		{
			var b = s.ReadByte();
			if (b == -1)
				throw new EndOfStreamException();
			return (byte)b;
		}

		public static ushort ReadUInt16(this Stream s)
		{
			return BitConverter.ToUInt16(s.ReadBytes(2), 0);
		}

		public static short ReadInt16(this Stream s)
		{
			return BitConverter.ToInt16(s.ReadBytes(2), 0);
		}

		public static uint ReadUInt32(this Stream s)
		{
			return BitConverter.ToUInt32(s.ReadBytes(4), 0);
		}

		public static int ReadInt32(this Stream s)
		{
			return BitConverter.ToInt32(s.ReadBytes(4), 0);
		}

		public static void Write(this Stream s, int value)
		{
			s.Write(BitConverter.GetBytes(value));
		}

		public static float ReadFloat(this Stream s)
		{
			return BitConverter.ToSingle(s.ReadBytes(4), 0);
		}

		public static double ReadDouble(this Stream s)
		{
			return BitConverter.ToDouble(s.ReadBytes(8), 0);
		}

		public static string ReadASCII(this Stream s, int length)
		{
			return new string(Encoding.ASCII.GetChars(s.ReadBytes(length)));
		}

		public static string ReadASCIIZ(this Stream s)
		{
			var bytes = new List<byte>();
			byte b;
			while ((b = s.ReadUInt8()) != 0)
				bytes.Add(b);
			return new string(Encoding.ASCII.GetChars(bytes.ToArray()));
		}

		public static string ReadAllText(this Stream s)
		{
			using (s)
			using (var sr = new StreamReader(s))
				return sr.ReadToEnd();
		}

		public static byte[] ReadAllBytes(this Stream s)
		{
			using (s)
				return s.ReadBytes((int)(s.Length - s.Position));
		}

		public static void Write(this Stream s, byte[] data)
		{
			s.Write(data, 0, data.Length);
		}

		public static IEnumerable<string> ReadAllLines(this Stream s)
		{
			using (var sr = new StreamReader(s))
			{
				for (;;)
				{
					var line = sr.ReadLine();
					if (line == null)
						yield break;
					else
						yield return line;
				}
			}
		}

		// The string is assumed to be length-prefixed, as written by WriteString()
		public static string ReadString(this Stream s, Encoding encoding, int maxLength)
		{
			var length = s.ReadInt32();
			if (length > maxLength)
				throw new InvalidOperationException("The length of the string ({0}) is longer than the maximum allowed ({1}).".F(length, maxLength));

			return encoding.GetString(s.ReadBytes(length));
		}

		// Writes a length-prefixed string using the specified encoding and returns
		// the number of bytes written.
		public static int WriteString(this Stream s, Encoding encoding, string text)
		{
			byte[] bytes;

			if (!string.IsNullOrEmpty(text))
				bytes = encoding.GetBytes(text);
			else
				bytes = new byte[0];

			s.Write(bytes.Length);
			s.Write(bytes);

			return 4 + bytes.Length;
		}
	}
}
