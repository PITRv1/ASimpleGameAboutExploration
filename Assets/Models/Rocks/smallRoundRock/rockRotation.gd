@tool
extends MeshInstance3D

func _process(delta: float) -> void:
	self.rotation.x += delta
	self.rotation.y += delta
	self.rotation.z += delta
