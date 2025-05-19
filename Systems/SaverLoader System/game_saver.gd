extends Node
class_name SaverLoader

const SAVE_GAME_PATH := "user://save_data.tres"
var playerRef : Player

func _ready() -> void:
	playerRef = Global.player


func writeSave():
	var saved_game : SavedGame = SavedGame.new()
	
	
	#Saving custom stuff here
	saved_game.avalible_weapons = playerRef.weapon_controller.avalible_weapons
	saved_game.money_amount = playerRef.inventory.money
	
	
	
	ResourceSaver.save(saved_game, SAVE_GAME_PATH)

func loadSave():
	var saved_game : SavedGame = load(SAVE_GAME_PATH)
	
	
	#Loading custom stuff here
	playerRef.weapon_controller.avalible_weapons = saved_game.avalible_weapons
	playerRef.inventory.set_money(saved_game.money_amount)
