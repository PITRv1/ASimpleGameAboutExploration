extends Node3D

@export var scene_to_load : String

var current_scene
var player_is_nerby : bool = false
var playerRef : Player
var max_distance : float

@onready var playerTriggerCollision : CollisionShape3D = $PortalNerbyTrigger/CollisionShape3D

func _ready() -> void:
	current_scene = get_tree()
	if playerTriggerCollision.shape is CylinderShape3D:
		max_distance = playerTriggerCollision.shape.radius

func load_scene(body):
	if body is Player:
		Global.game_controller.change_3d_scene(scene_to_load)

func _on_portal_nerby_trigger_body_entered(body: Node3D) -> void:
	if body is Player:
		player_is_nerby = true
		playerRef = body

func _on_portal_nerby_trigger_body_exited(body: Node3D) -> void:
	if body is Player:
		player_is_nerby = false
		

func _process(_delta: float) -> void:
	if player_is_nerby:
		var distance = self.global_position.distance_to(playerRef.global_position)
		var proximity = clamp(distance / max_distance, 0.0, 1.0)
		var eased = pow(proximity, 2) # or use exp curve
		
		var mat : ShaderMaterial = self.material_override
		if mat is ShaderMaterial:
			mat.set_shader_parameter("cutoff", eased)
