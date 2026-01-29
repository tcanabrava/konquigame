extends CharacterBody2D

class_name Konqui2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const JUMP_STRENGTH: float = 400.0
const WALKING_SPEED: float = 300.0
const RUNNING_SPEED: float = 200.0

var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var m_life: int = 1
var m_is_crouching: bool = false
var m_is_getting_up: bool = false
var m_is_crouched: bool = false
var m_flip_sprite: bool = false

func calc_horizontal_velocity(delta: float) -> float:
	if not is_on_floor():
		return velocity.x

	if m_is_crouched:
		return  float(lerp(velocity.x, 0.0, 6 * delta))
		
	var input_direction: float = Input.get_axis("left", "right")
	var is_running: bool = Input.is_action_pressed("run")
	
	if is_zero_approx(input_direction):
		return  float(lerp(velocity.x, 0.0, 5 * delta))

	m_flip_sprite = input_direction < 0.0
	
	var next_velocity = WALKING_SPEED
	if is_running:
		next_velocity += RUNNING_SPEED
	
	if input_direction < 0.0:
		next_velocity *= -1;

	return next_velocity

func apply_animation() -> void:
	if m_life == 0:
		if sprite.animation == "death":
			return
		sprite.play("death")
		return
	
	if not is_zero_approx(velocity.x):
		sprite.flip_h = m_flip_sprite

	if m_is_crouching:
		sprite.stop()
		sprite.play("crouch")
		return
		
	if m_is_crouched:
		return

	if m_is_getting_up:
		sprite.play_backwards("crouch")
		return

	if sprite.is_playing() && sprite.animation == "crouch":
		return

	if  not is_on_floor():
		if Input.is_action_pressed("jump"): # Jump just started
			sprite.play("jump")
		return

	if abs(velocity.x) > WALKING_SPEED:
		if sprite.animation != "run":
			sprite.play("run")
		return

	if abs(velocity.x) > 0.0:
		if sprite.animation != "walk" || !sprite.is_playing():
			sprite.play("walk")	
		return

	if is_zero_approx(velocity.x) && sprite.animation == "walk": 
		sprite.stop() 
		
	return

func handle_jumping(delta: float) -> bool:
	var is_jumping: bool = Input.is_action_just_pressed("jump")
	
	if is_on_floor() and is_jumping:
		velocity.y = -JUMP_STRENGTH

	velocity.y += delta * GRAVITY
	return is_jumping

func handle_death() -> bool:
	var is_dying: bool = Input.is_action_just_pressed("fakedeath")
	if is_dying:
		m_life=0
		apply_animation()
		set_physics_process(false)
	return is_dying
 
func handle_crouching() -> bool:
	m_is_crouching = Input.is_action_just_pressed("down")
	m_is_getting_up = Input.is_action_just_released("down")
	if !m_is_crouching && !m_is_getting_up:
		return false
		
	m_is_crouched = m_is_crouching || m_is_crouched
	if m_is_getting_up:
		m_is_crouched = false

	return true
	
func _physics_process(delta: float) -> void:
	if handle_death():
		return

	handle_jumping(delta)
	handle_crouching()
	velocity.x = calc_horizontal_velocity(delta)
	apply_animation()
	move_and_slide()
