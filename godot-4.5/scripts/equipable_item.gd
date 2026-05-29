extends Node

class_name EquipableItem
# This script defines how equipable items behave.
# They can be equiped / unequiped, and 
# when they are equiped, they can be in use, or not in use.

var equiped: bool = false
var in_use: bool = false

func equip() -> bool:
	print("Calling Equip")
	if equiped:
		return false

	equiped = true

	return true

func unequip() -> bool:
	print("Calling Unequip")
	if not equiped:
		return false

	equiped = false

	return true

func start_use() -> bool:
	print("Calling Start")

	if in_use: 
		return false

	in_use = true
	return true

func stop_use() -> bool:
	print("Calling Stop")

	if not in_use:
		return false

	in_use = false
	return true

func handle_flip_direction():
	pass
