using System;
using System.Collections.Generic;
using System.Linq;
using Eto;
using Eto.Forms;
using Eto.Drawing;
using libshp;

namespace SharpSHPBuilder
{
	public class Shp2PngWindow : Form, IFormIndexer
	{
		public string FormIndexer { get { return "shp2png"; } }

		public Shp2PngWindow()
		{
			Title = "shp >> png";
			Size = new Size(640, 480);
			WindowStyle = WindowStyle.None;

			var layout = new DynamicLayout();

			var openFile_dialog = new OpenFileDialog();
			openFile_dialog.CheckFileExists = true;
			openFile_dialog.MultiSelect = true;

			var sourcePals = SourceFileBox("Source pals.");
			var sourceShps = SourceFileBox("Source shps.");

			var lastDirectory = new Uri(EtoEnvironment.GetFolderPath(EtoSpecialFolder.ApplicationResources));

			var openSourceFile_button = ButtonExts.EventButton("Open Source Files", (sender, e) =>
				{
					openFile_dialog.Directory = lastDirectory;
					openFile_dialog.ShowDialog(this);
					var files = openFile_dialog.Filenames;

					var pals = files.Where(f => f.IsExt("pal"));
					var shps = files.Where(f => f.IsExt("shp"));

					foreach (var shp in shps)
						sourceShps.Items.Add(shp.JustFilename());

					foreach (var pal in pals)
						sourcePals.Items.Add(pal.JustFilename());

					lastDirectory = openFile_dialog.Directory;
				});

			var clearSourceFiles_button = ButtonExts.EventButton("Clear selected files", (sender, e) =>
				{
					var result = MessageBox.Show(this, "Are you sure?", "Clear files", MessageBoxButtons.YesNo);
					if (result == DialogResult.No)
						return;

					FormExts.ClearItems(sourcePals, sourceShps);
				});

			var convertToPng_button = ButtonExts.EventButton("Convert: shp >> png", (sender, e) =>
				{
					var shps = sourceShps.Items;
					var pals = sourcePals.Items;

					if (!shps.Any())
					{
						MessageBox.Show(this, "No files to convert.");
						return;
					}

					if (!pals.Any())
					{
						MessageBox.Show(this, "No pals to use.");
						return;
					}

					var pal = pals.First().Text;

					foreach (var shp in shps)
						Commands.ConvertSpriteToPng(shp.Text, pal);

					MessageBox.Show(this, "Frames converted successfully!");
				});

			var closeForm_button = ButtonExts.EventButton("Close form", (sender, e) => this.Close());

			layout.AddRow(openSourceFile_button, closeForm_button);

			layout.BeginHorizontal();
			layout.Add(sourcePals);
			layout.Add(sourceShps);
			layout.EndHorizontal();

			layout.AddRow
			(
				clearSourceFiles_button,
				convertToPng_button
			);

			Content = layout;
		}

		ListBox SourceFileBox(string tooltip)
		{
			var ret = new ListBox
			{
				Size = new Size((this.Size.Width / 2) - 1, 395)
			};

			ret.ToolTip = tooltip;

			return ret;
		}
	}
}
