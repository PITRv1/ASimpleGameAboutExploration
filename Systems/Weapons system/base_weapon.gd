extends Node
class_name BaseWeapon

@export var weapon_position : Vector3
@export var hitbox_component : HitboxComponent
@export var animation_player : AnimationPlayer



@export_category("Weapon Parameters")
@export var damage : float

@export_category("Visual Parameters")
@export var sway_min : Vector2 = Vector2(-20.0,-20.0)
@export var sway_max : Vector2 = Vector2(20.0,20.0)
@export_range(0,0.2,0.01) var sway_speed_position : float = 0.07
@export_range(0,0.2,0.01) var sway_speed_rotation : float = 0.1
@export_range(0,0.25,0.01) var sway_amount_position : float = 0.1
@export_range(0,50.0,0.1) var sway_amount_rotation : float = 30.0

@export var idle_sway_adjustment : float = 10.0
@export var idle_sway_rotation_strength : float = 300.0
@export_range(0.1,10.0,0.1) var random_sway_amount :float = 5.0

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
