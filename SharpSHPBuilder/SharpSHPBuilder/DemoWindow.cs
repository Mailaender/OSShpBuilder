using System;
using Xwt;

class DemoWindow
{
	[STAThread]
	static void Main()
	{
		Application.Initialize(ToolkitType.Gtk);
		var window = new Window()
		{
			Title = "Demoing Xwt",
			Width = 500,
			Height = 400
		};
		window.Show();
		Application.Run();
		window.Dispose();
	}
}
