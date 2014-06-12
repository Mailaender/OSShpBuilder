using System;
using Eto;
using Eto.Forms;
using Eto.Drawing;

namespace SharpSHPBuilder
{
	public class MainWindow : Form
	{
		public MainWindow()
		{
			Title = "EtoForm";
			Size = new Size(640, 480);

			var layout = new DynamicLayout();

			var tb = new TextBox();
			var input = new OpenFileDialog();

			var testbtn = ButtonExts.EventButton("open file", (sender, e) =>
				{
					input.ShowDialog(layout);
				});

			var exitButton = ButtonExts.EventButton("Quit!", (sender, e) => { Environment.Exit(-1); });

			tb.Text = input.CheckFileExists ? input.FileName : "No filename!";

			layout.BeginHorizontal();
			layout.AddColumn(testbtn, exitButton, tb);
			layout.EndHorizontal();

			Content = layout;
		}

		[STAThread]
		static void Main()
		{
			var generator = Generator.GetGenerator(Generators.GtkAssembly);
			var app = new Application(generator);

			var button = new Button();

			app.Initialized += delegate
			{
				app.MainForm = new MainWindow();
				app.MainForm.Show();
			};
			app.Run();
		}
	}
}
