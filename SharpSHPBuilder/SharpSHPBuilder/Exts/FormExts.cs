using System;
using System.Collections.Generic;
using System.Linq;
using Eto.Forms;

namespace SharpSHPBuilder
{
	public static class FormExts
	{
		public static void AddRange(this MenuItemCollection collection, params MenuItem[] items)
		{
			foreach (var item in items)
				collection.Add(item);
		}

		public static void AddRange(this List<Form> list, params Form[] forms)
		{
			foreach (var form in forms)
				list.Add(form);
		}

		public static Form GetIndexer(this List<Form> list, string indexer)
		{
			List<IFormIndexer> ifi = new List<IFormIndexer>();
			foreach (var item in list)
				ifi.Add(item as IFormIndexer);

			var form = ifi.FirstOrDefault(f => f.FormIndexer == indexer);
			if (form == null)
				throw new NullReferenceException("No form {0} found!".F(indexer));

			return form as Form;
		}

		public static void ClearItems(params ListBox[] boxes)
		{
			foreach (var box in boxes)
				box.ClearItems();
		}

		public static void ClearItems(this ListBox source)
		{
			source.Items.Clear();
		}
	}
}
