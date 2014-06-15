using System;
using System.IO;

namespace SharpSHPBuilder
{
	public static class StringExts
	{
		public static string JustFilename(this string str)
		{
			if (string.IsNullOrEmpty(str))
				return string.Empty;

			if (str.Trim().EndsWith(@"\"))
				return string.Empty;

			var last = str.LastIndexOf(Path.DirectorySeparatorChar);
			return str.Substring(last + 1);
		}

		public static bool IsExt(this string source, string value)
		{
			return source.EndsWith("." + value);
		}

		public static string F(this string str, params object[] objs)
		{
			return string.Format(str, objs);
		}
	}
}
