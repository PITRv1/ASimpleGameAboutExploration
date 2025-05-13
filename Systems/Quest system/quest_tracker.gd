extends Node
class_name QuestTracker

var activeQuest : Quest
var completedQuestList : Array

func trackNewQuest(quest : Quest):
	activeQuest = quest
	
func completeQuest(questTargetObjectID : int) -> bool:
	if activeQuest:
		if activeQuest.questTargetObjectID == questTargetObjectID:
			completedQuestList.append(activeQuest)
			
			print("questTracker :",questTargetObjectID)
			return true
	return false 
