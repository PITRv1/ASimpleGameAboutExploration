extends Node
class_name InputHandeler

signal onEscapePressed
signal onInteractPressed
signal onAttackPressed
signal onAdsHeld
signal onGrapplerFired

@export var escapeAction : GUIDEAction
@export var interactAction : GUIDEAction
@export var attackAction : GUIDEAction
@export var adsAction : GUIDEAction
@export var grapplerAction : GUIDEAction


func _ready() -> void:
	escapeAction.triggered.connect(escapePressed)
	interactAction.triggered.connect(interactPressed)
	
	attackAction.triggered.connect(attackPressed)
	adsAction.triggered.connect(adsPressed)
	grapplerAction.triggered.connect(grapplerFired)

func escapePressed():
	onEscapePressed.emit()

func interactPressed():
	onInteractPressed.emit()

func attackPressed():
	onAttackPressed.emit()

func adsPressed():
	onAdsHeld.emit()
	
func grapplerFired():
	onGrapplerFired.emit()
