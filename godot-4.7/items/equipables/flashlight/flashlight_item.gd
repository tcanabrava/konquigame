extends EquipableItem

class_name FlashlightItem

const FLASHLIGHT = preload("uid://d16b0wggnktl4")

## Power the flashlight burns per second while switched on.
const POWER_COST_PER_SECOND: float = 10.0

var flashlight_instance: PointLight2D = null

func _init() -> void:
	flashlight_instance = FLASHLIGHT.instantiate()
	power_cost_per_second = POWER_COST_PER_SECOND
	# The light scene defaults to visible; keep it dark until actually switched
	# on (start_use), so "light on" always matches "in use" / draining power.
	flashlight_instance.visible = false

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
	flashlight_instance.position = get_parent().item_position_marker.position
	flashlight_instance.scale.x *= -1
