using System;
using System.Diagnostics;
using System.Reflection;

namespace libshp
{
	public enum PlatformType { Unknown, Windows, OSX, Linux }

	public static class OSPlatform
	{
		public static PlatformType CurrentPlatform { get { return currentPlatform.Value; } }

		static Lazy<PlatformType> currentPlatform = Exts.Lazy(GetCurrentPlatform);

		static PlatformType GetCurrentPlatform()
		{
			if (Environment.OSVersion.Platform == PlatformID.Win32NT)
				return PlatformType.Windows;

			try
			{
				var psi = new ProcessStartInfo("uname", "-s");
				psi.UseShellExecute = false;
				psi.RedirectStandardOutput = true;
				var p = Process.Start(psi);
				var kernelName = p.StandardOutput.ReadToEnd();
				if (kernelName.Contains("Linux") || kernelName.Contains("BSD"))
					return PlatformType.Linux;
				if (kernelName.Contains("Darwin"))
					return PlatformType.OSX;
			}
			catch {	}

			return PlatformType.Unknown;
		}

		public static string RuntimeVersion
		{
			get
			{
				var mono = Type.GetType("Mono.Runtime");
				if (mono == null)
					return ".NET CLR {0}".F(Environment.Version);

				var version = mono.GetMethod("GetDisplayName", BindingFlags.NonPublic | BindingFlags.Static);
				if (version == null)
					return "Mono (unknown version) CLR {0}".F(Environment.Version);

				return "Mono {0} CLR {1}".F(version.Invoke(null, null), Environment.Version); 
			}
		}
	}
}
