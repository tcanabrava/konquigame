extends Node

class_name EquipableItem
# This script defines how equipable items behave.
# They can be equiped / unequiped, and 
# when they are equiped, they can be in use, or not in use.

var equiped: bool = false
var in_use: bool = false

## Power drained from the owner per second while this item is in use.
## Owners are expected to expose a `power` Stat. 0 means the item is free.
var power_cost_per_second: float = 0.0

func _physics_process(delta: float) -> void:
	if not in_use or power_cost_per_second <= 0.0:
		return

	var owner_power := _owner_power()
	if owner_power == null:
		return

	owner_power.change_by(-power_cost_per_second * delta)
	# Out of power: shut the item off. Subclasses handle the visible side via
	# their stop_use() override.
	if owner_power.is_empty():
		stop_use()

## The Power [Stat] of this item's owner, or null if the owner exposes none.
func _owner_power() -> Stat:
	var holder := get_parent()
	if holder == null:
		return null
	return holder.get(&"power") as Stat

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

	# Switch the item off first so we can never be "in use while unequipped"
	# (which would resume draining power the moment it's re-equipped).
	if in_use:
		stop_use()

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
