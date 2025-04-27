extends CharacterBody3D

@export var gravity := 16

func _physics_process(delta: float) -> void:
	self.velocity.y -= gravity * delta 
	
	move_and_slide()
