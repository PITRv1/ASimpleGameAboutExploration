extends Node3D
class_name HealthComponent

signal healthComponentDied

@export var health : float = 50
@export var max_health : float = 100

func Damage(value : float) -> void :
	if health - value > 0:
		health -= value
		return
	
	Die()
	
func Heal(value : float) -> void :
	if health + value < max_health:
		health += value
		return
	
	health = max_health
		
func Die():
	get_parent().queue_free()
	
	healthComponentDied.emit()
