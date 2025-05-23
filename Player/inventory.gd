extends Node
class_name Inventory

signal OnMoneyChanged(new_amount)

func add_money(value):
	Global.player.saveable_component.save_data_resource.money += value
	Global.player.saveable_component.has_changed = true
	emit_signal("OnMoneyChanged", Global.player.saveable_component.save_data_resource.money)

func subtract_money(value):
	Global.player.saveable_component.save_data_resource.money -= value
	Global.player.saveable_component.has_changed = true
	emit_signal("OnMoneyChanged", Global.player.saveable_component.save_data_resource.money)

func applySavedData():
	emit_signal("OnMoneyChanged", Global.player.saveable_component.save_data_resource.money)	
