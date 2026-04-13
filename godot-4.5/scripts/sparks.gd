extends Area2D

class_name Sparks

signal emit_shock_damage(damage: float)

func hit(_body: CharacterBody2D):
	print("hit no spark")
	emit_shock_damage.emit(1)
	
func _ready() -> void:
	print("conniction working")
	body_entered.connect(hit)
