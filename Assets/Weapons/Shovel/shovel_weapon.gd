extends BaseWeapon

var playerRef : Player
@export var reach : float = 5

var isHeld :bool = false
var chargupTimer : float

#========== This is a 2 state weapon its input action triggers both when pressing and releasing creating a chargeup system =========
func attack():
	#animation_player.play("attack")

	if not isHeld:
		isHeld = true
		
		
		
		return
	
	print("ReleasedHold")
	isHeld = false
	chargupTimer = 0.0
	
	playerRef = Global.player
	
	var current_root : Node3D = get_tree().current_scene
	var space_state : PhysicsDirectSpaceState3D = current_root.get_world_3d().direct_space_state
	var origin : Vector3 = playerRef.camera.global_position
	var direction : Vector3 = -playerRef.camera.global_transform.basis.z.normalized()
	
	#change reach to change reach
	var to : Vector3 = origin + direction * reach
	
	
	var query = PhysicsRayQueryParameters3D.create(origin, to)
	var result : Dictionary = space_state.intersect_ray(query)
	
	var normal : Vector3 
	
	if result:
		normal = result.normal

	playerRef.velocity += normal * 10
	
	

func ads():
	print("shovel aids")


func _on_hitbox_component_area_entered(area: Area3D) -> void:
	if area is HurtboxComponent:
		if area.parentIsPlayer: return
		
		area.Damage(damage)


func _process(delta: float) -> void:
	if isHeld:
		chargupTimer += delta
