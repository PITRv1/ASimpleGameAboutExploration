extends Node
class_name QuestGiver

@onready var saveable_component: SaveableComponent = $SaveableComponent

var quest_list : Array[Quest]
var latest_quest : Quest

func _ready() -> void:
	#Apply save data when the node is ready at this point the game will have loaded the 
	#applySavedData()
	pass

func giveQuest():
	var player : Player = Global.player
	
	if len(player.quest_tracker.getCompletedQuestList()) != 0:
		redeemQuest(player)
		return
	
	quest_list = saveable_component.save_data_resource.quest_list
	
	if not quest_list:
		print("Quest Giver :: ", "No quests avalible!")
		return
		
	latest_quest = quest_list.pick_random()
	player.quest_tracker.trackNewQuest(latest_quest)
	
	quest_list.erase(latest_quest)
	
	saveable_component.save_data_resource.quest_list = quest_list
	saveable_component.has_changed = true

func redeemQuest(player : Player):
	for quest : Quest in player.quest_tracker.getCompletedQuestList():
		player.inventory.add_money(quest.rewardMoneyAmount)
		
		print("Quest Giver :: Reward ", quest.rewardMoneyAmount)
		player.quest_tracker.removeFromCompleted(quest)
		
		latest_quest = null

func applySavedData():
	quest_list = saveable_component.save_data_resource.quest_list
