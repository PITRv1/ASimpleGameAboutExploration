extends CharacterBody3D
class_name QuestNPC

@export var gravity := 16


@export_category("Utilities")
@export var interactionReciver : InteractionReceiver
@export var questGiver : QuestGiver

var terrain : Terrain3D

func _ready() -> void:
	interactionReciver.OnInteractDetected.connect(OpenInteractionDialogue)
	_find_terrain()
	
func _find_terrain():
	var nodes = get_tree().get_nodes_in_group("current_terrain")
	if nodes.size() > 0:
		terrain = nodes[0]

func _physics_process(delta: float) -> void:
	velocity.y -= gravity * delta
	
	if terrain:
		var height: float = terrain.data.get_height(global_position)
		if not is_nan(height) and global_position.y <= height:
			global_position.y = height
			if velocity.y < 0.0:
				velocity.y = 0.0

	move_and_slide()



func OpenInteractionDialogue():
	questGiver.giveQuest()
