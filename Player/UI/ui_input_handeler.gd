extends Node
class_name InputHandeler

signal onEscapePressed
signal onInteractPressed

@export var escapeAction : GUIDEAction
@export var interactAction : GUIDEAction

func _ready() -> void:
	escapeAction.triggered.connect(escapePressed)
	interactAction.triggered.connect(interactPressed)

func escapePressed():
	onEscapePressed.emit()

func interactPressed():
	onInteractPressed.emit()
