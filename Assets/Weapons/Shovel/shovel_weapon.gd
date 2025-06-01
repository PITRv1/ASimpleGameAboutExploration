extends BaseWeapon

@export_category("Primary Attack")
@export var hit_reach : float = 5

@export_category("Secondary Ability")
@export var shield_reach : float = 5
@export var shield_knockback_power := 100


@onready var shield: MeshInstance3D = $Visual/Shield


var is_shielding := false

func _ready() -> void:
	shield.visible = false

func attack():
	animation_player.play("attack")
	

func ads():
	if !is_shielding:
		is_shielding = true
		shield.visible = true
		return
	is_shielding = false
	shield.visible = false

func _physics_process(delta: float) -> void:
	if is_shielding:
		knockback_player(delta)


func knockback_player(delta):
	var result = query_ray_ahead(shield_reach)
	var normal : Vector3 
	if result:
		normal = result.normal
	
	Global.player.velocity += normal * shield_knockback_power * delta


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
