using System;
using System.Collections.Generic;
using System.Linq;
using Eto;
using Eto.Forms;
using Eto.Drawing;
using libshp;

namespace SharpSHPBuilder
{
	public class MainWindow : Form
	{
		static Platform platform;

		public MainWindow()
		{
			Title = "EtoForm";
			Size = new Size(640, 480);

			var layout = new DynamicLayout();
			var toolbar = new ToolBar();

			var converter = new ConvertWindow();

			toolbar.Items.Add(ButtonExts.ToolbarEventButton("Open", (sender, e) => Console.WriteLine("todo: open files here")));
			toolbar.Items.Add(new SeparatorToolItem());
			toolbar.Items.Add(ButtonExts.ToolbarEventButton("Converter", (sender, e) => converter.Show()));

			// OSX menubar
			if (platform.IsMac) // if (Generator.Supports<MenuBar>())
			{
				var menuBar = new MenuBar();
				this.Menu = menuBar;
			}

			ToolBar = toolbar;

			Content = layout;
		}

		[STAThread]
		static void Main()
		{
			// OSX is *supposed to be* handled by our MacApp project, but isn't yet
			platform = Platform.Get(EtoEnvironment.Platform.IsWindows ? Platforms.WinForms : Platforms.Gtk2);

			var app = new Application(platform);
			app.Initialized += delegate
			{
				app.MainForm = new MainWindow();
				app.MainForm.Show();
			};
			app.Run();
		}
	}
}
