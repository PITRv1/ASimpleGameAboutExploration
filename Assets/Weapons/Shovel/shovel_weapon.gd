extends BaseWeapon

var playerRef : Player
@export var reach : float = 5
@export var max_charge_time : int = 3

var isHeld :bool = false
var chargupTimer : float = 1.0

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
	print("shovel aids")


func _on_hitbox_component_area_entered(area: Area3D) -> void:
	if area is HurtboxComponent:
		if area.parentIsPlayer: return
		
		area.Damage(damage)

func knockback_player():
	playerRef = Global.player
	
	var current_root : Node3D = Global.game_controller.current_3d_scene
	var space_state : PhysicsDirectSpaceState3D = current_root.get_world_3d().direct_space_state
	var origin : Vector3 = playerRef.camera.global_position
	var direction : Vector3 = -playerRef.camera.global_transform.basis.z.normalized()
	
	#change reach to change reach
	var to : Vector3 = origin + direction * reach
		
	var query = PhysicsRayQueryParameters3D.create(origin, to)
	var result : Dictionary = space_state.intersect_ray(query)
	
	var normal : Vector3 
	
	@warning_ignore("narrowing_conversion")
	var knockback_charge_mult : int = chargupTimer
	
	if result:
		normal = result.normal
	
	playerRef.velocity += normal * 10 * knockback_charge_mult
	


func _process(delta: float) -> void:
	if isHeld and chargupTimer < max_charge_time:
		chargupTimer += delta
