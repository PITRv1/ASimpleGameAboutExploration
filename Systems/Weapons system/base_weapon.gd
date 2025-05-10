extends Node
class_name BaseWeapon

@export var weapon_position : Vector3
@export var hitbox_component : HitboxComponent
@export var animation_player : AnimationPlayer



@export_category("Weapon Parameters")
@export var damage : float

func _ready() -> void:
	disableHitbox()

func attack():
	pass
	
func ads():
	pass


func disableHitbox():
	hitbox_component.monitoring = false

func enableHitbox():
	hitbox_component.monitoring = true
