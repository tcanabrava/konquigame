extends EquipableItem

class_name FlashlightItem

const FLASHLIGHT = preload("uid://d16b0wggnktl4")

var flashlight_instance = null

func _init() -> void:
	flashlight_instance = FLASHLIGHT.instantiate()

func equip() -> bool:
	if not super.equip():
		return false

	get_parent().add_child(flashlight_instance)
	return true

func unequip() -> bool:
	if not super.unequip():
		return false

	get_parent().remove_child(flashlight_instance)
	return true

func start_use() -> bool:
	if not super.start_use(): 
		return false

	flashlight_instance.visible = true
	return true

func stop_use():
	if not super.stop_use():
		return false

	flashlight_instance.visible = false
	return true
