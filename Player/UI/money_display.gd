extends Control

@export var money_container : RichTextLabel


var _first_tick_done := false

func _process(_delta):
	if not _first_tick_done:
		_first_tick_done = true
		var playerRef:Player = Global.player
		playerRef.inventory.connect("OnMoneyChanged", setMoneyDisplayAmount)

func setMoneyDisplayAmount(amount : int):
	money_container.text = "[rainbow freq=.2][outline_size={2}]" +str(amount)+ "[/outline_size][/rainbow]"
