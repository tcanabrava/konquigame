extends Node2D

class_name konqui_office

@onready var lights_out_timer: Timer = $LightsOutTimer
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

func turn_off_light():
	canvas_modulate.color = "#111111"

func turn_on_light():
	canvas_modulate.color = "#ffffff"

func _ready() -> void:
	turn_on_light()
	lights_out_timer.timeout.connect(turn_off_light)
	lights_out_timer.start(3)
