extends Node

class_name EquipableItem
# This script defines how equipable items behave.
# They can be equiped / unequiped, and 
# when they are equiped, they can be in use, or not in use.

var equiped: bool = false
var in_use: bool = false

func equip() -> bool:
	if equiped:
		return false

	return true

func unequip() -> bool:
	if not equiped:
		return false

	return true

func start_use() -> bool:
	if in_use: 
		return false

	return true

func stop_use() -> bool:
	if not in_use:
		return false

	return true
