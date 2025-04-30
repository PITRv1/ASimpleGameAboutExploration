extends CharacterBody3D

@export var interactionReciver : InteractionReceiver

@export var gravity := 16

func _ready() -> void:
	interactionReciver.OnInteractDetected.connect(OpenInteractionDialogue)


func OpenInteractionDialogue():
	print("You started interacition with me %s" % self.name)


func _physics_process(delta: float) -> void:
	self.velocity.y -= gravity * delta 
	
	move_and_slide()
