using System;
using System.Collections.Generic;
using System.Linq;
using Eto;
using Eto.Forms;
using Eto.Drawing;
using libshp;

namespace SharpSHPBuilder
{
	public class MainWindow : Form, IFormIndexer
	{
		static Platform platform;
		public List<Form> Forms;

		public string FormIndexer { get { return this.Title; } }

		public MainWindow()
		{
			Title = "Main Window";
			Size = new Size(640, 480);

			var layout = new DynamicLayout();
			var openFile_dialog = new OpenFileDialog();

			var shp2png = new Shp2PngWindow();
			var png2shp = new Png2ShpWindow();

			Forms = new List<Form>();

			Forms.AddRange
			(
				shp2png,
				png2shp
			);

			if (Generator.Supports<MenuBar>())
			{
				var menuBar = new MenuBar();
				menuBar.Items.AddRange
				(
					FileMenuButton(),
					OpenToolButton(shp2png, png2shp)
				);
				this.Menu = menuBar;
			}

			Content = layout;
		}

		ButtonMenuItem FileMenuButton()
		{
			var ret = new ButtonMenuItem();
			ret.Text = "File";
			ret.Shortcut = Keys.ForwardSlash;

			var fileButton = ButtonExts.MenuEventButton("Open", (sender, e) =>
				MessageBox.Show(this, "TODO", "Not implemented"));

			ret.Items.Add(fileButton);

			return ret;
		}

		ButtonMenuItem OpenToolButton(params Form[] forms)
		{
			var ret = new ButtonMenuItem();
			ret.Text = "Tools";
			ret.Shortcut = Keys.Backslash;

			var shp2png = ButtonExts.MenuEventButton("Shp >> Png", (sender, e) => ShowFormViaIndexer("shp2png"));
			var png2shp = ButtonExts.MenuEventButton("Png >> Shp", (sender, e) => ShowFormViaIndexer("png2shp"));

			ret.Items.AddRange
			(
				shp2png,
				png2shp
			);

			return ret;
		}

		Form ShowFormViaIndexer(string indexer)
		{
			var form = Forms.GetIndexer(indexer);
			form.Show();

			return form;
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
