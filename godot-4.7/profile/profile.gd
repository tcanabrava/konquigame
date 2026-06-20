extends TextureRect

class_name cyberpunk_profile

func _ready() -> void:
	hide()

func _unhandled_input(event):
	if not event.is_action_pressed("profile"):
		return

	if visible:
		get_tree().paused = false
		hide()
	else:
		show()
		get_tree().paused = true
