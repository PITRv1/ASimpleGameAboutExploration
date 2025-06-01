extends Node3D
class_name Grappler

@export var input_handeler : InputHandeler

@export_category("Grappler Settings")
@export var grapple_reach := 10.0
@export var rest_length := 2.0
@export var stiffness := 3.0
@export var damping := 2.0
@export var break_offset_factor := .5
@export var rope : Node3D


var grapple_point_visual_scene : PackedScene = preload("res://Player/Grappler/grapple_point.tscn")
var grapple_point_visual : Node3D

var is_grappling : bool = false
var can_grapple : bool = false
var max_grapple_radius: float

var breakplane_origin : Vector3
var breakplane_normal : Vector3

func _ready() -> void:
	input_handeler.onGrapplerFired.connect(onFireActionRecieved)
	
	grapple_point_visual = grapple_point_visual_scene.instantiate()
	await Global.game_controller.ready
	Global.game_controller.current_3d_scene.add_child(grapple_point_visual)
	hide_grappler_visual()


func onFireActionRecieved():
	if is_grappling:
		is_grappling = false
		break_grappler()
		return
		
	fire_grappler()


var target_position : Vector3
func _physics_process(delta: float) -> void:
	var result := query_ray_ahead(grapple_reach)
	if result: 
		Global.player.player_ui_controller.HUD.crosshair.draw_crosshair(Color.RED)
	else: 
		Global.player.player_ui_controller.HUD.crosshair.draw_crosshair(Color.BLACK)

	pull_in_player(delta)
	update_rope()
	
	
func fire_grappler():
	var result := query_ray_ahead(grapple_reach)
	if result:
		target_position = result["position"]

		var player_pos: Vector3 = Global.player.global_position
		var target_pos: Vector3 = target_position

		# Flatten positions onto XZ plane (ignore Y)
		player_pos.y = 0
		target_pos.y = 0

		# Direction from player to target on XZ plane
		var direction: Vector3 = (target_pos - player_pos).normalized()

		# Distance from player to target
		var distance: float = player_pos.distance_to(target_pos)

		# Optional push beyond the target (default = 0.2 means 20% beyond)
		var break_distance := distance * (1.0 + break_offset_factor)

		# Breakplane origin: further along the player → target direction
		breakplane_origin = player_pos + direction * break_distance

		# Plane normal: still pointing from player → target direction
		breakplane_normal = direction
		
		
		
		is_grappling = true
		
		show_grappler_visual()
		
func pull_in_player(delta):
	if !is_grappling or !target_position:
		return
	
	var target_dir = Global.player.global_position.direction_to(target_position)
	var target_dist = Global.player.global_position.distance_to(target_position)
	
	var displacement = target_dist - rest_length
	var force := Vector3.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = spring_force_magnitude * target_dir
		
		var vel_dot := Global.player.velocity.dot(target_dir)
		var applied_damping = -damping * vel_dot * target_dir
		
		force = spring_force + applied_damping
	
	Global.player.velocity += force * delta
	
	# Break conditions
	if target_dist < 5:
		break_grappler()
	
	# Break if player moves over a plane vertical to the player start pos and the target point.
	var current_pos = Global.player.global_position
	current_pos.y = 0

	var to_player = current_pos - breakplane_origin
	var dot = breakplane_normal.dot(to_player)

	if dot > 0.0:
		break_grappler()

func update_rope():
	if !is_grappling:
		rope.visible = false
		return
		
	rope.visible = true
	
	
	var view_dir = (target_position - Global.player.camera.global_position).normalized()
	var virtual_origin = target_position - view_dir * -0.01  # back it up slightly
	
	var dist = Global.player.global_position.distance_to(virtual_origin)
	rope.look_at(target_position)
	rope.scale = Vector3(1,1, dist - .5)
	
	grapple_point_visual.look_at(virtual_origin, Vector3.UP)
	

func break_grappler():
	is_grappling = false
	hide_grappler_visual()
	

func show_grappler_visual():	
	grapple_point_visual.global_position = target_position
	
	grapple_point_visual.visible = true
	
func hide_grappler_visual():
	grapple_point_visual.visible = false


func query_ray_ahead(length) -> Dictionary:
	var current_root : Node3D = Global.game_controller.current_3d_scene
	var space_state : PhysicsDirectSpaceState3D = current_root.get_world_3d().direct_space_state
	var origin : Vector3 = Global.player.camera.global_position
	var direction : Vector3 = -Global.player.camera.global_transform.basis.z.normalized()
	
	var to : Vector3 = origin + direction * length
		
	var query = PhysicsRayQueryParameters3D.create(origin, to)
	var result : Dictionary = space_state.intersect_ray(query)
	
	return result
