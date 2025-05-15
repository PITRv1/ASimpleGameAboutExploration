extends Control

@export var money_container : RichTextLabel

func _ready() -> void:
	var playerRef:Player = Global.player
	playerRef.inventory.OnMoneyChanged.connect(setMoneyDisplayAmount)
	
func setMoneyDisplayAmount(amount : int):
	money_container.text = "[rainbow freq=.2][outline_size={0}]" +str(amount)+ "[/outline_size][/rainbow]"
	
