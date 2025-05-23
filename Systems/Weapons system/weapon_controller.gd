extends Node3D
class_name WeaponController

@export var input_handeler : InputHandeler

@onready var weapon_origin_position: Marker3D = $WeaponOriginPosition


var all_weapons : Dictionary[String, PackedScene]= {
	"Fists" : preload("res://Assets/Weapons/Fists/fists_weapon.tscn"),
	"Shovel" : preload("res://Assets/Weapons/Shovel/shovel_weapon.tscn")
}

var avalible_weapons : Dictionary = {}

var current_weapon : BaseWeapon

func _ready() -> void:
	input_handeler.onAttackPressed.connect(attack)
	input_handeler.onAdsHeld.connect(ads)
	
	
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
