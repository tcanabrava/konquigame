extends Area2D

class_name StraigthFire

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var SPAWN_POINT: Vector2 = Vector2i(0,0)
var  TRAVEL_LENGTH: float = 0
var m_direction: int = 1
const SPEED: float = 800
const MAX_MOVEMENT: int = 800  

func _ready() -> void:
	connect("area_entered", hit)
	if m_direction == -1:
		sprite.flip_h = true;
		
func set_spawn_point(point: Vector2, direction: int):
	m_direction = direction
	SPAWN_POINT = point
	position = SPAWN_POINT


func hit():
		print("Fireball hit")
	
func _physics_process(delta: float) -> void:
	position.x += (SPEED * delta * m_direction) 

	TRAVEL_LENGTH += SPEED * delta
	if TRAVEL_LENGTH > MAX_MOVEMENT:
		print("Removing fireball")
		queue_free()
