using System;
using System.IO;

namespace SharpSHPBuilder
{
	public static class StringExts
	{
		public static string StripPathFromFilename(this string str)
		{
			if (string.IsNullOrEmpty(str))
				return string.Empty;

			if (str.Trim().EndsWith(@"\"))
				return string.Empty;

			var last = str.LastIndexOf(Path.DirectorySeparatorChar);
			return str.Substring(last + 1);
		}
	}
}
