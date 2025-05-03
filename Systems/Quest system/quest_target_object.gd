extends Node3D
class_name QuestTargetObject

signal onCollected

@export var targetObjectID : int


func collect():
	var player : Player = Global.player
	
	if player.quest_tracker.completeQuest(targetObjectID):
		print("collected : ", targetObjectID)
		
		onCollected.emit()
		self.queue_free()
