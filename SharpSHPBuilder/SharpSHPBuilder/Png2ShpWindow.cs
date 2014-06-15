using System;
using System.Linq;
using Eto;
using Eto.Forms;
using Eto.Drawing;
using libshp;

namespace SharpSHPBuilder
{
	public class Png2ShpWindow : Form, IFormIndexer
	{
		public string FormIndexer { get { return "png2shp"; } }

		public Png2ShpWindow()
		{
			Title = "png >> shp";
			Size = new Size(640, 480);
			WindowStyle = WindowStyle.None;

			var layout = new DynamicLayout();

			var openFile_dialog = new OpenFileDialog();
			openFile_dialog.CheckFileExists = true;
			openFile_dialog.MultiSelect = true;

			var lastDirectory = new Uri(EtoEnvironment.GetFolderPath(EtoSpecialFolder.ApplicationResources));

			var outputFolder_dialog = new SelectFolderDialog() { Directory = lastDirectory.AbsolutePath };

			var sourcePals = SourceFileBox("Source pals.");
			var sourcePngs = SourceFileBox("Source pngs.");

			var outputName_textbox = new TextBox() { PlaceholderText = "Output file name." };
			var outputDirectory = string.Empty;

			var openSourceFile_button = ButtonExts.EventButton("Open Source Files", (sender, e) =>
				{
					openFile_dialog.Directory = lastDirectory;
					var result = openFile_dialog.ShowDialog(this);

					if (result == DialogResult.Cancel)
						return;

					var files = openFile_dialog.Filenames;

					var pals = files.Where(f => f.IsExt("pal"));
					var pngs = files.Where(f => f.IsExt("png"));

					foreach (var png in pngs)
						sourcePngs.Items.Add(png.JustFilename());

					foreach (var pal in pals)
						sourcePals.Items.Add(pal.JustFilename());

					lastDirectory = openFile_dialog.Directory;
				});

			var selectOutputFolder_button = ButtonExts.EventButton("Select output folder", (sender, e) =>
				{
					var result = outputFolder_dialog.ShowDialog(this);
					if (result == DialogResult.Cancel)
						return;

					outputDirectory = outputFolder_dialog.Directory;

				});

			var clearSourceFiles_button = ButtonExts.EventButton("Clear selected files", (sender, e) =>
				{
					var result = MessageBox.Show(this, "Are you sure?", "Clear files", MessageBoxButtons.YesNo);
					if (result == DialogResult.No)
						return;

					ClearItems(sourcePals, sourcePngs);
				});

			var convertToShp_button = ButtonExts.EventButton("Convert to shp", (sender, e) =>
				{
					var pngs = sourcePngs.Items;
					var pals = sourcePals.Items;

					if (!pngs.Any())
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

					// BUG: output SHPs lose all frame metadata
					foreach (var png in pngs)
						Commands.ConvertPngToShp(pal, png.Text);

					MessageBox.Show(this, "PNGs packed successfully!");
				});

			var closeForm_button = ButtonExts.EventButton("Close form", (sender, e) => this.Close());

			layout.AddRow(openSourceFile_button, closeForm_button);

			layout.BeginHorizontal();
			layout.Add(sourcePals);
			layout.Add(sourcePngs);
			layout.EndHorizontal();

			layout.AddRow
			(
				clearSourceFiles_button,
				convertToShp_button
			);


			Content = layout;
		}

		ListBox SourceFileBox(string tooltip)
		{
			var ret = new ListBox
			{
				Size = new Size((this.Size.Width / 2) - 1, 380)
			};

			ret.ToolTip = tooltip;

			return ret;
		}

		void ClearItems(params ListBox[] boxes)
		{
			foreach (var box in boxes)
				box.Items.Clear();
		}
	}
}
