extends Node2D

class_name konqui_office

@onready var lights_out_timer: Timer = $LightsOutTimer
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var konqui: Konqui2D = $Konqui

const FlashlightItemScene = preload("uid://oc0lg1186ma8")
const DialogueBalloonScene = preload("uid://qdywlyykljc6")

func _on_dialogue_ended(resource: DialogueResource):
	if resource != DialogueBalloonScene:
		return

	canvas_modulate.color = "#111111"

func turn_off_light():
	DialogueManager.show_dialogue_balloon_scene("uid://djfjgwt1guy5f", DialogueBalloonScene, "start")
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func turn_on_light():
	canvas_modulate.color = "#ffffff"

func _ready() -> void:
	turn_on_light()
	lights_out_timer.timeout.connect(turn_off_light)
	lights_out_timer.start(3)

	var flashlight = FlashlightItemScene.new()
	konqui.add_child(flashlight)
	konqui.set_current_equipment(flashlight)
