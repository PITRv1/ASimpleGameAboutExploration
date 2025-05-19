extends Node
class_name SaverLoader

const SAVE_GAME_PATH := "user://save_data.tres"
var playerRef : Player

func _ready() -> void:
	playerRef = Global.player
	#clearSave()
	
func writeSave():
	var saved_game : SavedGame = SavedGame.new()
	
	
	#Saving custom stuff here
	saved_game.avalible_weapons = playerRef.weapon_controller.avalible_weapons
	
	saved_game.money_amount = playerRef.inventory.money
	
	saved_game.activeQuest = playerRef.quest_tracker.activeQuest
	saved_game.completedQuestList = playerRef.quest_tracker.completedQuestList
	
	ResourceSaver.save(saved_game, SAVE_GAME_PATH)


func loadSave():
	var saved_game : SavedGame = load(SAVE_GAME_PATH)
	if not saved_game:
		return
	
	
	#Loading custom stuff here
	playerRef.weapon_controller.avalible_weapons = saved_game.avalible_weapons
	
	playerRef.inventory.set_money(saved_game.money_amount)
	
	playerRef.quest_tracker.activeQuest = saved_game.activeQuest
	playerRef.quest_tracker.completedQuestList = saved_game.completedQuestList


func clearSave():
	var cleared_data := SavedGame.new()
	ResourceSaver.save(cleared_data, SAVE_GAME_PATH)
	print("SaverLoader: ", "Save file cleared.")
