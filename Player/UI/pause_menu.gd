extends Control
class_name  PauseMenu

func PauseGame():
	if get_tree().paused:
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func VisibiliyChanged() -> void:	
	PauseGame()

func callDefaultSaveCreation():
	Global.game_controller.saver_loader.createDefaultSave()
