extends BaseWeapon

@export_category("Primary Attack")
@export var hit_reach : float = 5
@export var max_charge_time : int = 3

@export_category("Secondary Ability")
@export var grapple_reach : float = 100
@export var pull_force := 50.0
@export var slack_radius: float = 3.0

var isHeld :bool = false
var chargupTimer : float = 1.0

var is_grappling : bool = false
var can_grapple : bool = false
var max_grapple_radius: float

var break_plane_normal: Vector3
var initial_distance: float

#========== This is a 2 state weapon its input action triggers both when pressing and releasing creating a chargeup system =========
func attack():
	if not isHeld:
		isHeld = true
		animation_player.play("charge_up")

		return
	
	isHeld = false
	chargupTimer = 1.0
	animation_player.play("attack")
	knockback_player()

func ads():
	fire_grappler()


func _process(delta: float) -> void:
	if isHeld and chargupTimer < max_charge_time:
		chargupTimer += delta


var target_position : Vector3
func _physics_process(delta: float) -> void:
	var result := query_ray_ahead(grapple_reach)
	if result: 
		Global.player.player_ui_controller.HUD.crosshair.draw_crosshair(Color.RED)
	else: 
		Global.player.player_ui_controller.HUD.crosshair.draw_crosshair(Color.BLACK)

		
		
	if not(is_grappling and target_position):
		return
		
	pull_in_player(delta)
	

func knockback_player():
	@warning_ignore("narrowing_conversion")
	var knockback_charge_mult : int = chargupTimer
	
	var result = query_ray_ahead(hit_reach)
	var normal : Vector3 
	if result:
		normal = result.normal
	
	Global.player.velocity += normal * 10 * knockback_charge_mult



func fire_grappler():
	var result := query_ray_ahead(grapple_reach)
	if result:
		target_position = result["position"]
		initial_distance = Global.player.global_position.distance_to(target_position)
		break_plane_normal = (target_position - Global.player.global_position).normalized()
		max_grapple_radius = Global.player.global_position.distance_to(target_position) + slack_radius
		is_grappling = true
		
		var grapple_point_visual : Node3D = load("res://Assets/Weapons/Shovel/grapple_pointvisual.tscn").instantiate()
		grapple_point_visual.global_position = target_position
		Global.game_controller.current_3d_scene.add_child(grapple_point_visual)
		

func pull_in_player(delta):
	var player_pos = Global.player.global_position
	var to_target = (target_position - player_pos)
	var current_distance  = to_target.length()

	if current_distance > max_grapple_radius:
		var direction_to_target = to_target.normalized()
		var clamped_position = target_position - direction_to_target * max_grapple_radius
		var correction_vector = clamped_position - player_pos
		Global.player.velocity += correction_vector * pull_force * 100 * delta
	else:
		Global.player.velocity += to_target.normalized() * pull_force * delta

	if current_distance < 5.0:
		is_grappling = false
		return

	var from_start_to_player = Global.player.global_position - target_position
	var dot = break_plane_normal.dot(from_start_to_player)
	if dot > 0:
		is_grappling = false
		return


func query_ray_ahead(length) -> Dictionary:
	var current_root : Node3D = Global.game_controller.current_3d_scene
	var space_state : PhysicsDirectSpaceState3D = current_root.get_world_3d().direct_space_state
	var origin : Vector3 = Global.player.camera.global_position
	var direction : Vector3 = -Global.player.camera.global_transform.basis.z.normalized()
	
	var to : Vector3 = origin + direction * length
		
	var query = PhysicsRayQueryParameters3D.create(origin, to)
	var result : Dictionary = space_state.intersect_ray(query)
	
	return result
	
	
	
func _on_hitbox_component_area_entered(area: Area3D) -> void:
	if area is HurtboxComponent:
		if area.parentIsPlayer: return
		
		area.Damage(damage)
