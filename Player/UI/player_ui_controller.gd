extends Control
class_name PlayerUIController

@export var input_handeler : InputHandeler

@export_group("UI elements")
@export var HUD : PlayerHud

@export var pause_menu : PauseMenu

enum UIElement {
	PAUSE_MENU
}

func _ready() -> void:
	pause_menu.visible = false
	input_handeler.onEscapePressed.connect(inputHandelerOnEscapePressed)


func ShowUIElement(element : UIElement) -> void:
	match element:
		UIElement.PAUSE_MENU:
			pause_menu.visible = true
			
func HideUIElement(element : UIElement) -> void:
	match element:
		UIElement.PAUSE_MENU:
			pause_menu.visible = false

#Hides all elements (Except the HUD)
func HideALlUIElements():
	pause_menu.visible = false


func inputHandelerOnEscapePressed():
	if get_tree().paused:
		get_tree().paused = false
		HideUIElement(UIElement.PAUSE_MENU)
		return
	
	get_tree().paused = true
	ShowUIElement(UIElement.PAUSE_MENU)
