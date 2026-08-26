extends Area2D

class_name StraigthFire

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var spawn_point: Vector2 = Vector2(0, 0)
var travel_length: float = 0
var m_direction: int = 1
const SPEED: float = 800
const MAX_MOVEMENT: float = 800

func _ready() -> void:
	# Detect both Area2D hitboxes and physics bodies (the player/enemies are
	# CharacterBody2D, which area_entered alone would miss).
	area_entered.connect(hit)
	body_entered.connect(hit)
	_update_facing()

func _update_facing() -> void:
	if sprite == null:
		return
	sprite.flip_h = m_direction == -1

func set_spawn_point(point: Vector2, direction: int):
	m_direction = direction
	spawn_point = point
	position = spawn_point
	# Reapply facing in case the spawn point is set after the node is ready.
	if is_node_ready():
		_update_facing()


func hit(_target: Node2D):
	print("Fireball hit")

func _physics_process(delta: float) -> void:
	position.x += (SPEED * delta * m_direction)

	travel_length += SPEED * delta
	if travel_length > MAX_MOVEMENT:
		print("Removing fireball")
		queue_free()
