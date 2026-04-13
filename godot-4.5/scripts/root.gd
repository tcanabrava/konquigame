extends Node2D

@onready var konqui_2d: Konqui2D = $Konqui2D
@onready var sparks: Sparks = $Sparks

func deal_shock_damage(damage:float):
	konqui_2d.receive_damage(damage, "shock")

func  _ready() -> void:
	sparks.emit_shock_damage.connect(deal_shock_damage)
