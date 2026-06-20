extends Node2D

class_name EletronicDoor

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	lock()

func unlock():
	animated_sprite_2d.play("unlocked")

func lock():
	animated_sprite_2d.play("locked")
	
func open():
	animated_sprite_2d.play("opening")

func request_unlock():
	print("Requesting to unlock door")
