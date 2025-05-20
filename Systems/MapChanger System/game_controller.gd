extends Node
class_name GameController

@export var world_3d : Node3D
@export var gui : Control

@export_category("Saver System")
@export var saver_loader : SaverLoader

var current_3d_scene : Node3D
var current_gui_scene : Control

func _init() -> void:
	Global.game_controller = self

func _ready() -> void:
	current_3d_scene = $World3D/HubWorld
	Global.game_controller.saver_loader.loadSave()

func change_3d_scene(new_scene : String, delete : bool = true, keep_running : bool = false) -> void :
	if current_3d_scene != null:
		if delete:
			current_3d_scene.queue_free()
		elif keep_running:
			current_3d_scene.visible = false
		else:
			world_3d.remove_child(current_3d_scene)
	var new = load(new_scene).instantiate()
	world_3d.add_child(new)
	current_3d_scene = new
	Global.game_controller.saver_loader.loadSave()

func change_gui_scene(new_scene : String, delete : bool = true, keep_running : bool = false) -> void :
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new
