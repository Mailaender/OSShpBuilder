using System;
using Eto.Forms;

namespace SharpSHPBuilder
{
	public static class LayoutExts
	{
		public static void AddRange(this DynamicLayout layout, params Control[] controls)
		{
			foreach (var control in controls)
				layout.Add(control);
		}
	}
}
