extends CanvasLayer

## Full-screen character/inventory overlay toggled with the "profile" action.
## Root is a CanvasLayer so it stays fixed to the screen regardless of the
## Camera2D, and process_mode = ALWAYS so it still receives input while the
## game is paused.
class_name cyberpunk_profile

func _ready() -> void:
	visible = false

func _unhandled_input(event):
	if not event.is_action_pressed("profile"):
		return

	if visible:
		get_tree().paused = false
		visible = false
	else:
		visible = true
		get_tree().paused = true
