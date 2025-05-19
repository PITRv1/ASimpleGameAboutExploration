extends Node
class_name QuestTracker

var activeQuest : Quest
var completedQuestList : Array

func trackNewQuest(quest : Quest):
	activeQuest = quest
	print(activeQuest.questName)
	Global.player.saver_loader.writeSave()
	
	
func completeQuest(questTargetObjectID : int) -> bool:
	if activeQuest:
		if activeQuest.questTargetObjectID == questTargetObjectID:
			completedQuestList.append(activeQuest)
			
			print("questTracker :",questTargetObjectID)
			Global.player.saver_loader.writeSave()
			return true
	return false
	
func removeFromCompleted(quest : Quest):
	completedQuestList.erase(quest)
	Global.player.saver_loader.writeSave()
