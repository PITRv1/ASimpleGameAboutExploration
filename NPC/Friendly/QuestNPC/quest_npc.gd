extends CharacterBody3D

@export var interactionReciver : InteractionReceiver
@export var questGiver : QuestGiver


@export var gravity := 16

func _ready() -> void:
	interactionReciver.OnInteractDetected.connect(OpenInteractionDialogue)

func _physics_process(delta: float) -> void:
	self.velocity.y -= gravity * delta 
	
	move_and_slide()



func OpenInteractionDialogue():
	questGiver.giveQuest()
