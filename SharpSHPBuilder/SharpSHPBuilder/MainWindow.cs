using System;
using Eto;
using Eto.Forms;
using Eto.Drawing;

namespace SharpSHPBuilder
{
	public class MainWindow : Form
	{
		public MainWindow(Generator generator) : base(generator)
		{
			Text = "EtoForm";
			Size = new Size(200, 200);
		}

		[STAThread]
		static void Main()
		{
			var generator = Generator.GetGenerator("Eto.Platform.GtkSharp.Generator, Eto.Platform.GtkSharp");

			var app = new Application();
			app.Initialized += delegate
			{
				app.MainForm = new MainWindow(generator);
				app.MainForm.Show();
			};
			app.Run();
		}
	}
}
