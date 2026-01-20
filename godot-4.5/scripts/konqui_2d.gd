extends CharacterBody2D

class_name Konqui2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var JUMP_STRENGTH: float = 800.0
var WALKING_SPEED: float = 300.0
var RUNNING_SPEED: float = 200.0
var LIFE: int = 1

func calc_horizontal_velocity(delta: float) -> float:
	var input_direction: float = Input.get_axis("left", "right")
	var is_running: bool = Input.is_action_pressed("run")

	if not is_on_floor():
		return velocity.x

	if is_zero_approx(input_direction):
		return  float(lerp(velocity.x, 0.0, 10 * delta))

	var next_velocity = WALKING_SPEED
	if is_running:
		next_velocity += RUNNING_SPEED
	
	if input_direction < 0.0:
		next_velocity *= -1;

	return next_velocity

func apply_animation() -> void:
	if LIFE == 0:
		if sprite.animation == "death":
			return
		sprite.play("death")
		return
	
	if not is_zero_approx(velocity.x):
		sprite.flip_h = velocity.x < 0

	if  not is_on_floor():
		if Input.is_action_pressed("jump"): # Jump just started
			sprite.play("jump")
		return

	if abs(velocity.x) > WALKING_SPEED:
		if sprite.animation != "run":
			sprite.play("run")
		return

	if abs(velocity.x) > 0.0:
		if sprite.animation != "walk":
			sprite.play("walk")	
		return

	if is_zero_approx(velocity.x):
		sprite.stop() 
		
	return

func _physics_process(delta: float) -> void:
	var is_dying: bool = Input.is_action_just_pressed("fakedeath")
	if is_dying:
		LIFE=0
		apply_animation()
		return
		
	var is_jumping: bool = Input.is_action_just_pressed("jump")
	
	if is_on_floor() and is_jumping:
		velocity.y = -JUMP_STRENGTH

	velocity.y += delta * GRAVITY
	velocity.x = calc_horizontal_velocity(delta)
	apply_animation()
	move_and_slide()
