using System;
using Eto.Forms;

namespace SharpSHPBuilder
{
	public static class ButtonExts
	{
		public static bool Clicked(this Button btn)
		{
			Console.WriteLine("{0} pressed!", btn.Text);
			return true;
		}

		public static Button EventButton(EventHandler<EventArgs> e)
		{
			return EventButton(string.Empty, e);
		}

		public static Button EventButton(string text, EventHandler<EventArgs> e)
		{
			var ret = new Button();
			ret.Text = text;
			ret.Click += e;

			return ret;
		}
	}
}

