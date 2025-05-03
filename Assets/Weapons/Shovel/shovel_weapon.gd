extends BaseWeapon

func attack():
	animation_player.play("attack")

func ads():
	print("shovel aids")


func _on_hitbox_component_area_entered(area: Area3D) -> void:
	if area is HurtboxComponent:
		if area.parentIsPlayer: return
		
		area.Damage(damage)
