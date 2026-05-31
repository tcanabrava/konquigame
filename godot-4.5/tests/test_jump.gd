extends Node2D

class_name TestJump

@onready var btn_double_jump: CheckButton = $DoubleJump
@onready var btn_wall_jump: CheckButton = $WallJump
@onready var btn_wall_grab: CheckButton = $WallGrab
@onready var konqui: Konqui2D = $Konqui

func _ready():
	btn_double_jump.pressed.connect(_on_btn_double_jump_pressed)
	btn_wall_jump.pressed.connect(_on_btn_wall_jump_pressed)
	btn_wall_grab.pressed.connect(_on_btn_wall_grab_pressed)

func _on_btn_double_jump_pressed():
	konqui.can_double_jump = btn_double_jump.is_pressed()

func _on_btn_wall_jump_pressed():
	konqui.can_wall_jump = btn_wall_jump.is_pressed()

func _on_btn_wall_grab_pressed():
	konqui.can_wall_grab = btn_wall_grab.is_pressed()
