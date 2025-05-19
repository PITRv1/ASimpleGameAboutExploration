extends Node3D
class_name WeaponController

@export var input_handeler : InputHandeler
@export var saver_loader : SaverLoader

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
	
	
	#avalible_weapons["Shovel"] = all_weapons["Shovel"]
	#equip_weapon(avalible_weapons["Shovel"])
	

func equip_weapon(weapon_scene : PackedScene):
	var weapon_instance : BaseWeapon = weapon_scene.instantiate()
	weapon_instance.position = weapon_instance.weapon_position
	
	add_child(weapon_instance)
	
	current_weapon = weapon_instance

	
func attack():
	current_weapon.attack()
	
func ads():
	current_weapon.ads()
