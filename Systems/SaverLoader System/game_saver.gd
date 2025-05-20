extends Node
class_name SaverLoader

const SAVE_GAME_PATH := "user://save_data.tres"
const DEFAULT_SAVE_PATH := "user://default_save_data.tres"
var playerRef : Player
var latest_save : SavedGame

func _ready() -> void:
	clearSave()
	pass
	
func writeSave():
	playerRef = Global.player
	
	var saved_game : SavedGame = latest_save if latest_save else SavedGame.new()

	var saveables := get_tree().get_nodes_in_group("saveable")

	for component:SaveableComponent in saveables:
		if component.has_changed and component.save_data_resource:
			saved_game.component_data[component.save_id] = component.save_data_resource.duplicate()
			component.has_changed = false
	
	#Saving custom stuff here
	saved_game.avalible_weapons = playerRef.weapon_controller.avalible_weapons
	
	saved_game.money_amount = playerRef.inventory.money
	
	#Quest value Saves
	#Player side:
	saved_game.activeQuest = playerRef.quest_tracker.activeQuest
	saved_game.completedQuestList = playerRef.quest_tracker.completedQuestList
	

	ResourceSaver.save(saved_game, SAVE_GAME_PATH)
	latest_save = saved_game

func loadSave():
	playerRef = Global.player
	
	if not FileAccess.file_exists(SAVE_GAME_PATH):
		print("Save file missing, restoring default.")
		clearSave()

	var saved_game = load(SAVE_GAME_PATH) as SavedGame
	
	# Apply saved data to SaveableComponents
	var saveables := get_tree().get_nodes_in_group("saveable")

	for component:SaveableComponent in saveables:
		if saved_game.component_data.has(component.save_id):
			var saved_data = saved_game.component_data[component.save_id]
			if saved_data:
				component.save_data_resource = saved_data.duplicate()
				component.onDataLoaded.emit()
	
	
	#Loading custom stuff here
	playerRef.weapon_controller.avalible_weapons = saved_game.avalible_weapons
	
	playerRef.inventory.set_money(saved_game.money_amount)
	
	playerRef.quest_tracker.activeQuest = saved_game.activeQuest
	playerRef.quest_tracker.completedQuestList = saved_game.completedQuestList


func clearSave():
	var default_data := load(DEFAULT_SAVE_PATH) as SavedGame
	var cloned_data = default_data.duplicate(true)
	
	#Save defa data into the normal save file's location
	ResourceSaver.save(cloned_data, SAVE_GAME_PATH)
	print("GameSaver: Reset to default values.")

func createDefaultSave():
	playerRef = Global.player
	
	var saved_game : SavedGame = SavedGame.new()
	
	var saveables := get_tree().get_nodes_in_group("saveable")

	for component:SaveableComponent in saveables:
		if component.has_changed and component.save_data_resource:
			saved_game.component_data[component.save_id] = component.save_data_resource.duplicate()
			component.has_changed = false
	
	#Saving custom stuff here
	saved_game.avalible_weapons = playerRef.weapon_controller.avalible_weapons
	
	saved_game.money_amount = playerRef.inventory.money
	
	#Quest value Saves
	#Player side:
	saved_game.activeQuest = playerRef.quest_tracker.activeQuest
	saved_game.completedQuestList = playerRef.quest_tracker.completedQuestList
	
	ResourceSaver.save(saved_game, DEFAULT_SAVE_PATH)
