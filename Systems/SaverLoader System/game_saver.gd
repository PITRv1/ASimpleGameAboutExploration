extends Node
class_name SaverLoader

const SAVE_GAME_PATH := "user://save_data.tres"

@onready var weapon_controller: WeaponController = $"../../Head/CameraSmooth/PlayerCamera/WeaponController"

func writeSave():
	var saved_game : SavedGame = SavedGame.new()
	
	
	#Saving custom stuff here
	saved_game.avalible_weapons = weapon_controller.avalible_weapons
	
	
	ResourceSaver.save(saved_game, SAVE_GAME_PATH)
#
func loadSave():
	var saved_game : SavedGame = load(SAVE_GAME_PATH)
	
	
	#Loading custom stuff here
	weapon_controller.avalible_weapons = saved_game.avalible_weapons
