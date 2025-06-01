extends CharacterBody3D
class_name QuestNPC

@export var gravity := 16


@export_category("Utilities")
@export var interactionReciver : InteractionReceiver
@export var questGiver : QuestGiver

@onready var tween : Tween


var terrain : Terrain3D

func _ready() -> void:
	interactionReciver.OnInteractDetected.connect(OpenInteractionDialogue)
	_find_terrain()
	
func _find_terrain():
	var nodes = get_tree().get_nodes_in_group("current_terrain")
	if nodes.size() > 0:
		terrain = nodes[0]


var is_turning : bool = false
func _physics_process(delta: float) -> void:
	velocity.y -= gravity * delta
	
	if terrain:
		var height: float = terrain.data.get_height(global_position)
		if not is_nan(height) and global_position.y <= height:
			global_position.y = height
			if velocity.y < 0.0:
				velocity.y = 0.0
	
	
	if is_turning:
		var dir = (Global.player.global_position - global_position)
		dir.y = 0.0
		dir = dir.normalized()
		
		var desired_rotation = atan2(-dir.x, -dir.z) # Y-rotation to look at target
		if tween:
			tween.kill()

		tween = get_tree().create_tween()
		tween.tween_property(self, "rotation:y", desired_rotation, 0.3).set_ease(Tween.EASE_OUT_IN)
		is_turning = false

	
	move_and_slide()


var resource = load("res://Assets/dialogues/quest_npc_dialogue.dialogue")

func OpenInteractionDialogue():
	is_turning = true

	var dialogue_line = await resource.get_next_dialogue_line("start")
	DialogueManager.show_dialogue_balloon(resource, "start")
	
	#dialogue_line = await resource.get_next_dialogue_line(dialogue_line.next_id)
	#DialogueManager.show_dialogue_balloon(resource, dialogue_line.next_id)
	#
	#
	#dialogue_line = await resource.get_next_dialogue_line(dialogue_line.next_id)
	#print(dialogue_line.text)
	#dialogue_line = await resource.get_next_dialogue_line(dialogue_line.next_id)
	#print(dialogue_line.text)
	#dialogue_line = await resource.get_next_dialogue_line(dialogue_line.next_id)
	#print(dialogue_line.text)
	
	
	
	questGiver.giveQuest()


func is_looking_at(target: Node3D, max_angle_deg: float = 20.0) -> bool:
	var forward = -global_transform.basis.z.normalized()
	var to_target = (target.global_position - global_position).normalized()
	
	var angle = forward.angle_to(to_target)
	return rad_to_deg(angle) < max_angle_deg
