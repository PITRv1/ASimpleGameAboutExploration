extends Node3D

@export var scene_to_load : PackedScene

var current_scene
var player_is_nerby : bool = false
var playerRef : Player
var max_distance : float

@onready var playerTriggerCollision : CollisionShape3D = $PortalNerbyTrigger/CollisionShape3D
@onready var protalMesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	current_scene = get_tree()
	if playerTriggerCollision.shape is CylinderShape3D:
		max_distance = playerTriggerCollision.shape.radius

func load_scene(body):
	if body is Player:
		if scene_to_load:
			get_tree().change_scene_to_packed(scene_to_load)


func _on_portal_nerby_trigger_body_entered(body: Node3D) -> void:
	if body is Player:
		player_is_nerby = true
		playerRef = body

func _on_portal_nerby_trigger_body_exited(body: Node3D) -> void:
	if body is Player:
		player_is_nerby = false
		

func _process(delta: float) -> void:
	if player_is_nerby:
		var distance = self.global_position.distance_to(playerRef.global_position)
		var proximity = clamp(distance / max_distance, 0.0, 1.0)
		var eased = pow(proximity, 2) # or use exp curve
		
		var mat := protalMesh.get_active_material(0)
		if mat is ShaderMaterial:
			mat.set_shader_parameter("cutoff", eased)
