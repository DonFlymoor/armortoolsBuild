package arm.ui;

import haxe.io.Bytes;
import kha.Blob;
import zui.Zui;
import zui.Ext;
import zui.Id;
import iron.data.Data;
import arm.sys.Path;

class TabScript {

	public static var hscript = Id.handle();
	static var textColoring: TTextColoring = null;

	@:access(zui.Zui)
	public static function draw(htab: Handle) {
		var ui = UIBase.inst.ui;
		var statush = Config.raw.layout[LayoutStatusH];
		if (ui.tab(htab, tr("Script")) && statush > UIStatus.defaultStatusH * ui.SCALE()) {

			ui.beginSticky();
			if (Config.raw.touch_ui) {
				ui.row([1 / 4, 1 / 4, 1 / 4, 1 / 4]);
			}
			else {
				ui.row([1 / 14, 1 / 14, 1 / 14, 1 / 14]);
			}
			if (ui.button(tr("Run"))) {
				try {
					js.Lib.eval(hscript.text);
				}
				catch(e: Dynamic) {
					Console.log(e);
				}
			}
			if (ui.button(tr("Clear"))) {
				hscript.text = "";
			}
			if (ui.button(tr("Import"))) {
				UIFiles.show("js", false, false, function(path: String) {
					Data.getBlob(path, function(b: Blob) {
						hscript.text = b.toString();
						Data.deleteBlob(path);
					});
				});
			}
			if (ui.button(tr("Export"))) {
				var str = hscript.text;
				UIFiles.show("js", true, false, function(path: String) {
					var f = UIFiles.filename;
					if (f == "") f = tr("untitled");
					path = path + Path.sep + f;
					if (!path.endsWith(".js")) path += ".js";
					Krom.fileSaveBytes(path, Bytes.ofString(str).getData());
				});
			}
			ui.endSticky();

			var _font = ui.ops.font;
			var _fontSize = ui.fontSize;
			Data.getFont("font_mono.ttf", function(f: kha.Font) { ui.ops.font = f; }); // Sync
			ui.fontSize = Std.int(15 * ui.SCALE());
			Ext.textAreaLineNumbers = true;
			Ext.textAreaScrollPastEnd = true;
			Ext.textAreaColoring = getTextColoring();
			Ext.textArea(ui, hscript);
			Ext.textAreaLineNumbers = false;
			Ext.textAreaScrollPastEnd = false;
			Ext.textAreaColoring = null;
			ui.ops.font = _font;
			ui.fontSize = _fontSize;
		}
	}

	static function getTextColoring(): TTextColoring {
		if (textColoring == null) {
			Data.getBlob("text_coloring.json", function(blob: Blob) {
				textColoring = haxe.Json.parse(blob.toString());
			});
		}
		return textColoring;
	}
}
