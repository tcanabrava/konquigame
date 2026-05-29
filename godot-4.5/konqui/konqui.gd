extends CharacterBody2D

class_name Konqui2D

@onready var flashlight: PointLight2D = $Flashlight
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var crouch_shape: CollisionShape2D = $CrouchShape
@onready var normal_shape: CollisionShape2D = $NormalShape
@onready var attack_timer: Timer = $AttackTimer

const JUMP_STRENGTH: float = 400.0
const WALKING_SPEED: float = 300.0
const RUNNING_SPEED: float = 200.0

var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var m_life: int = 1
var m_is_crouching: bool = false
var m_is_getting_up: bool = false
var m_is_crouched: bool = false
var m_flip_sprite: bool = false
var m_triggered_attack: bool = false
var m_is_shocked: bool = false
var current_equipment: EquipableItem = null
var current_software = null

func _ready() -> void:
	flashlight.visible = false
	
func receive_damage(damage: float, type: String):
	print("Damage received", damage, type)

func calc_horizontal_velocity(delta: float):
	if not is_on_floor():
		return

	
	if m_is_crouched:
		velocity.x = float(lerp(velocity.x, 0.0, 6 * delta))
		return
		
	var input_direction: float = Input.get_axis("left", "right")
	var is_running: bool = Input.is_action_pressed("run")
	
	if is_zero_approx(input_direction):
		velocity.x = float(lerp(velocity.x, 0.0, 6 * delta))
		return
		
	m_flip_sprite = input_direction < 0.0
	
	var next_velocity = WALKING_SPEED
	if is_running:
		next_velocity += RUNNING_SPEED
	
	if input_direction < 0.0:
		next_velocity *= -1;

	velocity.x = next_velocity
	return

func apply_animation() -> void:
	if m_life == 0:
		var death_anim = ""
		var death_animation = randi() % 100
		if death_animation <= 50:
			death_anim = "dying_impact"
		else:
			death_anim = "dying_normal"
			
		if sprite.animation == death_anim:
			return

		sprite.play(death_anim)
		return
	
	handle_flip_graphics()

	if m_triggered_attack:
		sprite.play("attack")
		m_triggered_attack = false
		return

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

func handle_flip_graphics():
	if sprite.flip_h == m_flip_sprite:
		return

	if is_zero_approx(velocity.x):
		return

	sprite.flip_h = m_flip_sprite
	
	flashlight.rotate(PI)
	flashlight.position.x *= -1


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

	crouch_shape.disabled = !m_is_crouched
	normal_shape.disabled = m_is_crouched
	
	return true

func handle_attack():
	if !attack_timer.is_stopped():
		return
	flashlight.visible = false

	var is_attacking = Input.is_action_just_pressed("attack")
	if !is_attacking:
		return

	flashlight.visible = true
	m_triggered_attack = true
	attack_timer.start()


func _physics_process(delta: float) -> void:
	if handle_death():
		return

	handle_jumping(delta)
	handle_crouching()
	handle_attack()
	calc_horizontal_velocity(delta)
	apply_animation()
	move_and_slide()
