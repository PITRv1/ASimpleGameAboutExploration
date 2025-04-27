extends Control
class_name  PauseMenu

var playerRef : Player

func _ready() -> void:
	playerRef = Global.player


func PauseGame():
	if get_tree().paused:
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	

func VisibiliyChanged() -> void:	
	PauseGame()
