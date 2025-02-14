package arm.ui;

import zui.Zui;
import zui.Id;
import iron.object.MeshObject;
import arm.util.MeshUtil;

class TabMeshes {

	@:access(zui.Zui)
	public static function draw(htab: Handle) {
		var ui = UIBase.inst.ui;
		var statush = Config.raw.layout[LayoutStatusH];
		if (ui.tab(htab, tr("Meshes")) && statush > UIStatus.defaultStatusH * ui.SCALE()) {

			ui.beginSticky();

			#if (is_paint || is_sculpt)
			if (Config.raw.touch_ui) {
				ui.row([1 / 6, 1 / 6, 1 / 6, 1 / 6, 1 / 6, 1 / 6]);
			}
			else {
				ui.row([1 / 14, 1 / 9, 1 / 9, 1 / 9, 1 / 9, 1 / 14]);
			}
			#end

			#if is_lab
			if (Config.raw.touch_ui) {
				ui.row([1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7]);
			}
			else {
				ui.row([1 / 14, 1 / 9, 1 / 9, 1 / 9, 1 / 9, 1 / 9, 1 / 14]);
			}
			#end

			if (ui.button(tr("Import"))) {
				UIMenu.draw(function(ui: Zui) {
					if (UIMenu.menuButton(ui, tr("Replace Existing"), '${Config.keymap.file_import_assets}')) {
						Project.importMesh(true);
					}
					if (UIMenu.menuButton(ui, tr("Append"))) {
						Project.importMesh(false);
					}
				}, 2);
			}
			if (ui.isHovered) ui.tooltip(tr("Import mesh file"));

			#if is_lab
			if (ui.button(tr("Set Default"))) {
				UIMenu.draw(function(ui: Zui) {
					if (UIMenu.menuButton(ui, tr("Cube"))) setDefaultMesh(".Cube");
					if (UIMenu.menuButton(ui, tr("Plane"))) setDefaultMesh(".Plane");
					if (UIMenu.menuButton(ui, tr("Sphere"))) setDefaultMesh(".Sphere");
					if (UIMenu.menuButton(ui, tr("Cylinder"))) setDefaultMesh(".Cylinder");
				}, 4);
			}
			#end

			if (ui.button(tr("Flip Normals"))) {
				MeshUtil.flipNormals();
				Context.raw.ddirty = 2;
			}

			if (ui.button(tr("Calculate Normals"))) {
				UIMenu.draw(function(ui: Zui) {
					if (UIMenu.menuButton(ui, tr("Smooth"))) { MeshUtil.calcNormals(true); Context.raw.ddirty = 2; }
					if (UIMenu.menuButton(ui, tr("Flat"))) { MeshUtil.calcNormals(false); Context.raw.ddirty = 2; }
				}, 2);
			}

			if (ui.button(tr("Geometry to Origin"))) {
				MeshUtil.toOrigin();
				Context.raw.ddirty = 2;
			}

			if (ui.button(tr("Apply Displacement"))) {
				#if is_paint
				MeshUtil.applyDisplacement(Project.layers[0].texpaint_pack);
				#end
				#if is_lab
				MeshUtil.applyDisplacement(arm.logic.BrushOutputNode.inst.texpaint_pack, 0.05, Context.raw.brushScale);
				#end

				MeshUtil.calcNormals();
				Context.raw.ddirty = 2;
			}

			if (ui.button(tr("Rotate"))) {
				UIMenu.draw(function(ui: Zui) {
					if (UIMenu.menuButton(ui, tr("Rotate X"))) {
						MeshUtil.swapAxis(1, 2);
						Context.raw.ddirty = 2;
					}

					if (UIMenu.menuButton(ui, tr("Rotate Y"))) {
						MeshUtil.swapAxis(2, 0);
						Context.raw.ddirty = 2;
					}

					if (UIMenu.menuButton(ui, tr("Rotate Z"))) {
						MeshUtil.swapAxis(0, 1);
						Context.raw.ddirty = 2;
					}
				}, 3);
			}

			ui.endSticky();

			for (i in 0...Project.paintObjects.length) {
				var o = Project.paintObjects[i];
				var h = Id.handle();
				h.selected = o.visible;
				o.visible = ui.check(h, o.name);
				if (ui.isHovered && ui.inputReleasedR) {
					UIMenu.draw(function(ui: Zui) {
						if (UIMenu.menuButton(ui, tr("Export"))) {
							Context.raw.exportMeshIndex = i + 1;
							BoxExport.showMesh();
						}
						if (Project.paintObjects.length > 1 && UIMenu.menuButton(ui, tr("Delete"))) {
							Project.paintObjects.remove(o);
							while (o.children.length > 0) {
								var child = o.children[0];
								child.setParent(null);
								if (Project.paintObjects[0] != child) {
									child.setParent(Project.paintObjects[0]);
								}
								if (o.children.length == 0) {
									Project.paintObjects[0].transform.scale.setFrom(o.transform.scale);
									Project.paintObjects[0].transform.buildMatrix();
								}
							}
							iron.data.Data.deleteMesh(o.data.handle);
							o.remove();
							Context.raw.paintObject = Context.mainObject();
							MeshUtil.mergeMesh();
							Context.raw.ddirty = 2;
						}
					}, Project.paintObjects.length > 1 ? 2 : 1);
				}
				if (h.changed) {
					var visibles: Array<MeshObject> = [];
					for (p in Project.paintObjects) if (p.visible) visibles.push(p);
					MeshUtil.mergeMesh(visibles);
					Context.raw.ddirty = 2;
				}
			}
		}
	}

	#if is_lab
	static function setDefaultMesh(name: String) {
		var mo: MeshObject = cast iron.Scene.active.getChild(name);
		mo.visible = true;
		iron.Scene.active.meshes = [mo];
		Context.raw.ddirty = 2;
		Context.raw.paintObject = mo;
		#if (kha_direct3d12 || kha_vulkan)
		arm.render.RenderPathRaytrace.ready = false;
		#end
	}
	#end
}
