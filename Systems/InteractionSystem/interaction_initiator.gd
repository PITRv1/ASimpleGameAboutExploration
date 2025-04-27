extends Node3D
class_name InteractionInitiator

@export var inputHandeler : InputHandeler
@export var handReachDistance : float = 4.0

@onready var rayCast: RayCast3D = $"."

func _ready() -> void:
	inputHandeler.onInteractPressed.connect(queryInteractionSpace)

func queryInteractionSpace():
	rayCast.target_position = Vector3(0,0, -handReachDistance)
	
	var collider : InteractionReceiver = rayCast.get_collider()
	
	if collider: 
		initateInteraction(collider)
		
func initateInteraction(interactionReciever : InteractionReceiver):
	interactionReciever.triggerInteraction()
