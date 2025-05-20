extends Node
class_name Inventory

signal OnMoneyChanged(new_amount)

var money : int

func add_money(value):
	money += value
	emit_signal("OnMoneyChanged", money)

func subtract_money(value):
	money -= value
	emit_signal("OnMoneyChanged", money)

func set_money(value):
	money = value
	emit_signal("OnMoneyChanged", money)
	
	
