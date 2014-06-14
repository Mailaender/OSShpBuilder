using System;
using Eto.Forms;

namespace SharpSHPBuilder
{
	public static class ButtonExts
	{
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

		public static ButtonToolItem ToolbarEventButton(string text, EventHandler<EventArgs> e)
		{
			var ret = new ButtonToolItem();
			ret.Text = text;
			ret.Click += e;

			return ret;
		}
	}
}
