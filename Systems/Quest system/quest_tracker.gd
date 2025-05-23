extends Node
class_name QuestTracker

var activeQuest : Quest
#var completedQuestList : Array

func trackNewQuest(quest : Quest):
	#Save it into the resource as well but keep the local var cause I dont want to type this much
	Global.player.saveable_component.save_data_resource.activeQuest = quest
	Global.player.saveable_component.has_changed = true
	activeQuest = quest
	
	print("Player:QuestTracker :: ",activeQuest.questName)
	
func completeQuest(questTargetObjectID : int) -> bool:
	if activeQuest:
		if activeQuest.questTargetObjectID == questTargetObjectID:
			
			Global.player.saveable_component.save_data_resource.completedQuestList.append(activeQuest)
			
			Global.player.saveable_component.save_data_resource.activeQuest = null
			activeQuest = null
			
			Global.player.saveable_component.has_changed = true
			
			print("Player:QuestTracker :: ID ", questTargetObjectID)
			return true
	return false
	
func removeFromCompleted(quest : Quest):
	Global.player.saveable_component.save_data_resource.completedQuestList.erase(quest)
	Global.player.saveable_component.has_changed = true

func getCompletedQuestList() -> Array:
	return Global.player.saveable_component.save_data_resource.completedQuestList


func applySavedData():
	activeQuest = Global.player.saveable_component.save_data_resource.activeQuest
