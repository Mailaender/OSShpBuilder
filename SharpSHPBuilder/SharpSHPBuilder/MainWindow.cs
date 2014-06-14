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

			var labelShpFilename = new Label() { Text = "Shp file: " };
			var labelPalFilename = new Label() { Text = "Pal file: " };
			var labelLastOperation = new Label() { Text = "No operation." };

			var openDialog = new OpenFileDialog();
			openDialog.CheckFileExists = true;

			var lastDirectory = new Uri(EtoEnvironment.GetFolderPath(EtoSpecialFolder.ApplicationResources));

			var selectShpFileButton = ButtonExts.EventButton("Select SHP", (sender, e) =>
				{
					openDialog.Directory = lastDirectory;

					openDialog.ShowDialog(labelShpFilename);
					labelShpFilename.Text = openDialog.FileName.StripPathFromFilename() ?? "No shp!";
					lastDirectory = openDialog.Directory;
					labelLastOperation.Text = "Selected shp file.";
				});

			var selectPalFileButton = ButtonExts.EventButton("Select PAL", (sender, e) =>
				{
					openDialog.Directory = lastDirectory;

					openDialog.ShowDialog(labelPalFilename);
					labelPalFilename.Text = openDialog.FileName.StripPathFromFilename() ?? "No pal!";
					lastDirectory = openDialog.Directory;
					labelLastOperation.Text = "Selected pal file.";
				});

			var convertToPngButton = ButtonExts.EventButton("Convert to png.", (sender, e) =>
				{
					var shp = labelShpFilename.Text;
					var pal = labelPalFilename.Text;

					if (string.IsNullOrEmpty(shp) || string.IsNullOrEmpty(pal))
					{
						labelLastOperation.Text = "Operation failed! Did you select a .pal and .shp?";
						return;
					}

					if (!labelShpFilename.Text.Contains(".shp") || !labelPalFilename.Text.Contains(".pal"))
					{
						labelLastOperation.Text = "Operation failed! One of the selected files is not the correct file type.";
						return;
					}

					Commands.ConvertSpriteToPng(shp, pal);
					labelLastOperation.Text = "Extracted {0}'s frames to .pngs!".F(shp);
				});

			var quitButton = ButtonExts.EventButton("Quit!", (sender, e) => { Environment.Exit(-1); });

			// OSX menubar
			if (platform.IsMac) // if (Generator.Supports<MenuBar>())
			{
				var menuBar = new MenuBar();
				this.Menu = menuBar;
			}

			layout.BeginVertical();
			layout.AddRange
			(
				selectShpFileButton, selectPalFileButton,
				convertToPngButton, quitButton,
				labelShpFilename, labelPalFilename,
				labelLastOperation
			);
			layout.EndVertical();

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
