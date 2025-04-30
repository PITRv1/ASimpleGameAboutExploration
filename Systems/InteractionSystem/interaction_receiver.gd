extends Node3D
class_name InteractionReceiver

signal OnInteractDetected

func triggerInteraction():
	OnInteractDetected.emit()
