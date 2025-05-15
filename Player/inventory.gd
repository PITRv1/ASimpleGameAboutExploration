extends Node
class_name Inventory

signal OnMoneyChanged(new_amount)

var money : int:
	get: return money
	set(value):
		if money != value:
			money = value
			emit_signal("OnMoneyChanged", value)
