@tool
extends EditorPlugin

var import_plugin
var MapResource = load("res://addons/afmi_godot/AzgaarMap.gd")

func _enter_tree():
	import_plugin = preload("import_plugin.gd").new()
	MapResource = load("res://addons/afmi_godot/AzgaarMap.gd")
	add_import_plugin(import_plugin)

func _exit_tree():
	remove_import_plugin(import_plugin)
	import_plugin = null
