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

			Closed += (sender, e) => Quit(false);

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

				var fileMenu = menuBar.Items.GetSubmenu("&File");
				fileMenu.Shortcut = Keys.F & Keys.Control;
				fileMenu.Items.AddRange
				(
					ButtonMenuItem("Open", (sender, e) => MessageBox.Show(this, "TODO", "Open")),
					ButtonMenuItem("Quit", (sender, e) => Quit())
				);

				menuBar.Items.Add(ToolMenuButton(shp2png, png2shp));
				this.Menu = menuBar;
			}

			Content = layout;
		}

		ButtonMenuItem ButtonMenuItem(string text, EventHandler<EventArgs> e)
		{
			var ret = new ButtonMenuItem();
			ret.Text = text;
			ret.Click += e;

			return ret;
		}

		ButtonMenuItem ToolMenuButton(params Form[] forms)
		{
			var ret = new ButtonMenuItem();
			ret.Text = "Tools";
			ret.Shortcut = Keys.Backslash;

			var shp2png = ButtonExts.MenuEventButton("Shp >> Png", (sender, e) => ShowFormViaIndexer("shp2png"));
			var png2shp = ButtonExts.MenuEventButton("Png >> Shp", (sender, e) =>
				{
					MessageBox.Show(this, "This is buggy!", "Do not use.");
					ShowFormViaIndexer("png2shp");
				});

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

		void Quit(bool needConfirmation = true)
		{
			if (needConfirmation)
			{
				var result = MessageBox.Show(this, "Quit?", MessageBoxButtons.YesNo);
				if (result == DialogResult.No)
					return;
			}

			foreach (var form in Forms.Where(f => f.Visible))
				form.Close();

			Environment.Exit(-1);
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
