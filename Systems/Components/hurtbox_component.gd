extends Area3D
class_name HurtboxComponent

@export var health_component : HealthComponent

@export var parentIsPlayer : bool = false


func Damage(value : float):
	health_component.Damage(value)

func Heal(value : float):
	health_component.Heal(value)
