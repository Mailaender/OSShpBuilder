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

			var shpFilenameLabel = new Label();
			var palFilenameLabel = new Label();
			var operationLabel = new Label() { Text = "No operation." };

			var openDialog = new OpenFileDialog();

			openDialog.CheckFileExists = true;

			var selectShpFileButton = ButtonExts.EventButton("Select SHP", (sender, e) =>
				{
					// nasty HACK as workaround to "Recent Items" dir causing NRE
					openDialog.Directory = new Uri(EtoEnvironment.GetFolderPath(EtoSpecialFolder.Documents));

					openDialog.ShowDialog(shpFilenameLabel);
					shpFilenameLabel.Text = openDialog.FileName ?? "No shp!";
					operationLabel.Text = "Selected shp file.";
				});

			var selectPalFileButton = ButtonExts.EventButton("Select PAL", (sender, e) =>
				{
					// nasty HACK as workaround to "Recent Items" dir causing NRE
					openDialog.Directory = new Uri(EtoEnvironment.GetFolderPath(EtoSpecialFolder.Documents));

					openDialog.ShowDialog(palFilenameLabel);
					palFilenameLabel.Text = openDialog.FileName ?? "No pal!";
					operationLabel.Text = "Selected pal file.";
				});

			var convertToPngButton = ButtonExts.EventButton("Convert to png.", (sender, e) =>
				{
					var shp = shpFilenameLabel.Text;
					var pal = palFilenameLabel.Text;

					if (string.IsNullOrEmpty(shp) || string.IsNullOrEmpty(pal))
					{
						Console.WriteLine("The shp or pal file is null or was not selected.");
						return;
					}

					if (!shpFilenameLabel.Text.Contains(".shp") || !palFilenameLabel.Text.Contains(".pal"))
					{
						Console.WriteLine("One of the selected files is not the correct file type (extension).");
						return;
					}

					Commands.ConvertSpriteToPng(new[] {shp, pal} );
					operationLabel.Text = "Converted {0} to png!".F(shp);
				});

			var quitButton = ButtonExts.EventButton("Quit!", (sender, e) => { Environment.Exit(-1); });

//			// OSX menubar
//			if (platform.IsMac) // if (Generator.Supports<MenuBar>())
//			{
//				var menuBar = new MenuBar();
//				this.Menu = menuBar;
//			}

			layout.AddColumn
			(
				selectShpFileButton, selectPalFileButton,
				convertToPngButton, quitButton,
				shpFilenameLabel, palFilenameLabel,
				operationLabel
			);

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
