extends Node
class_name QuestGiver

@export var quest_list : Array[Quest]

var current_quest : Quest
func giveQuest():
	if current_quest: 
		redeemQuest()
		return
	
	if not quest_list:
		print("No quests avalible!")
		return
		
	current_quest = quest_list.pick_random()
	
	var player : Player = Global.player
	player.quest_tracker.trackNewQuest(current_quest)
	
	quest_list.erase(current_quest)
		
func redeemQuest():
	var player : Player = Global.player
	if len(player.quest_tracker.completedQuestList) != 0:
		for quest : Quest in player.quest_tracker.completedQuestList:
			player.inventory.add_money(quest.rewardMoneyAmount)
			
			print("Quest Giver :", quest.rewardMoneyAmount)
			player.quest_tracker.removeFromCompleted(quest)
			
			current_quest = null
