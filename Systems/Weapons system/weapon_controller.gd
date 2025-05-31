extends Node3D
class_name WeaponController

@export var input_handeler : InputHandeler

@export var sway_noise : NoiseTexture2D
@export var sway_speed : float = 1.2

var all_weapons : Dictionary[String, PackedScene]= {
	"Fists" : preload("res://Assets/Weapons/Fists/fists_weapon.tscn"),
	"Shovel" : preload("res://Assets/Weapons/Shovel/shovel_weapon.tscn")
}

var avalible_weapons : Dictionary = {}
var current_weapon : BaseWeapon

var mouse_movement : Vector2
var random_sway_x
var random_sway_y
var random_sway_amount : float
var time : float = 0.0
var idle_sway_adjustment
var idle_sway_rotaion_strenght
var weapon_bob_amount : Vector2 = Vector2(0,0)


func _ready() -> void:
	input_handeler.onAttackPressed.connect(attack)
	input_handeler.onAdsHeld.connect(ads)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative


func equip_weapon(weapon_scene : PackedScene):
	var weapon_instance : BaseWeapon = weapon_scene.instantiate()
	weapon_instance.position = weapon_instance.weapon_position
	
	add_child(weapon_instance)
	
	current_weapon = weapon_instance


func giveNewWeapon(new_weapon : PackedScene, weapon_name : String):
	Global.player.saveable_component.save_data_resource.avalible_weapons[weapon_name] = new_weapon
	Global.player.saveable_component.has_changed = true
	avalible_weapons[weapon_name] = new_weapon


func attack():
	current_weapon.attack()
	
func ads():
	current_weapon.ads()


func applySavedData():
	
	#ERROR TODO The weapon only loads from the deafult save the first time around when loading the second it crashes
	#I put a bandaid on it for now come back to later PLS
	
	Global.player.saveable_component.save_data_resource.avalible_weapons["Shovel"] = all_weapons["Shovel"]
	avalible_weapons = Global.player.saveable_component.save_data_resource.avalible_weapons
	equip_weapon(avalible_weapons["Shovel"])




func sway_weapon(delta, isIdle : bool)->void:
	if not current_weapon: return
	
	mouse_movement = mouse_movement.clamp(current_weapon.sway_min, current_weapon.sway_max)
	
	if isIdle:
		var sway_random : float = get_sway_noise()
		var sway_random_adjusted : float = sway_random * idle_sway_adjustment 
		
		time += delta * (sway_speed + sway_random)
		random_sway_x = sin(time * 1.5 + sway_random_adjusted) / random_sway_amount
		random_sway_y = sin(time - sway_random_adjusted) / random_sway_amount
	
	
		position.x = lerp(position.x, current_weapon.position.x - (mouse_movement.x * current_weapon.sway_amount_position + random_sway_x) * delta, current_weapon.sway_speed_position)
		position.y = lerp(position.y, current_weapon.position.y + (mouse_movement.y * current_weapon.sway_amount_position + random_sway_y) * delta, current_weapon.sway_speed_position)
		
		rotation_degrees.y = lerp(rotation_degrees.y, current_weapon.rotation.y + (mouse_movement.x * current_weapon.sway_amount_rotation + (random_sway_y * idle_sway_rotaion_strenght)) * delta, current_weapon.sway_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.x, current_weapon.rotation.x - (mouse_movement.y * current_weapon.sway_amount_rotation + (random_sway_x * idle_sway_rotaion_strenght)) * delta, current_weapon.sway_speed_rotation)
	
	
	else:
		position.x = lerp(position.x, current_weapon.position.x - (mouse_movement.x * current_weapon.sway_amount_position + weapon_bob_amount.x) * delta, current_weapon.sway_speed_position)
		position.y = lerp(position.y, current_weapon.position.y + (mouse_movement.y * current_weapon.sway_amount_position + weapon_bob_amount.y) * delta, current_weapon.sway_speed_position)
		
		rotation_degrees.y = lerp(rotation_degrees.y, current_weapon.rotation.y + (mouse_movement.x * current_weapon.sway_amount_rotation) * delta, current_weapon.sway_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.x, current_weapon.rotation.x - (mouse_movement.y * current_weapon.sway_amount_rotation) * delta, current_weapon.sway_speed_rotation)


func get_sway_noise() -> float:
	var player_position : Vector3 = Vector3(0,0,0)
	
	if not Engine.is_editor_hint():
		player_position = Global.player.global_position
		
	var noise_location: float = sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
	return noise_location

func weapon_bob(delta, bob_speed: float, hbob_amount: float, vbob_amount: float) ->void:
	time += delta
	
	weapon_bob_amount.x = sin(time * bob_speed) * hbob_amount
	weapon_bob_amount.y = abs(cos(time * bob_speed) * vbob_amount)
