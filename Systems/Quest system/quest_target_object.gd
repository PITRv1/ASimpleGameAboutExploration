extends Node3D
class_name QuestTargetObject

signal onCollected

@export var targetObjectID : int
@export var saveable_component : SaveableComponent


func collect():
	var player : Player = Global.player
	
	if player.quest_tracker.completeQuest(targetObjectID):
		print("QuestTargetObject :: ID ",targetObjectID)
		
		saveable_component.save_data_resource.is_collected = true
		saveable_component.has_changed = true
		
		onCollected.emit()
		self.visible = false

func applySavedData():
	if saveable_component.save_data_resource.is_collected == true:
		self.visible = false
		self.queue_free()
