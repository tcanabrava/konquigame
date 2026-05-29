extends EquipableItem

class_name FlashlightItem

const FLASHLIGHT = preload("uid://d16b0wggnktl4")

var flashlight_instance: PointLight2D = null

func _init() -> void:
	flashlight_instance = FLASHLIGHT.instantiate()

func equip() -> bool:
	if not super.equip():
		return false

	var parent = get_parent()

	parent.add_child(flashlight_instance)
	flashlight_instance.position = parent.item_position_marker.position

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

func handle_flip_direction():
	var parent = get_parent()
	print(parent.item_position_marker.position)
	print(parent.item_position_marker.transform)

	flashlight_instance.position = get_parent().item_position_marker.position
	flashlight_instance.scale.x *= -1
