extends CharacterBody2D

class_name Konqui2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var crouch_shape: CollisionShape2D = $CrouchShape
@onready var normal_shape: CollisionShape2D = $NormalShape
@onready var attack_timer: Timer = $AttackTimer
@onready var item_position_marker: Marker2D = $ItemPositionMarker

const JUMP_STRENGTH: float = 400.0
const WALKING_SPEED: float = 300.0
const RUNNING_SPEED: float = 200.0
const WALL_DRAG_FALL_SPEED: float = 20.0

const PROFILE_SCENE: PackedScene = preload("uid://gpi8gwa5sddr")
var profile_scene: Node = null

var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var m_life: int = 1
var m_is_crouching: bool = false
var m_is_getting_up: bool = false
var m_is_crouched: bool = false
var m_is_dragging: bool = false
var m_flip_sprite: bool = false

# Disable fall should be used to prevent
# the phisics engine to move the downwards or to completely
# change how gravity works, such as when you are flying
# or dragging on the wall.
var m_disable_fall: bool = false
var m_triggered_attack: bool = false
var m_is_shocked: bool = false
var current_equipment: EquipableItem = null
var current_software = null

var can_double_jump: bool = false
var can_wall_jump: bool = false
var can_wall_grab: bool = false
var double_jump_count: int = 0

func set_current_equipment(equipment: EquipableItem):
	current_equipment = equipment

func _ready() -> void:
	profile_scene = PROFILE_SCENE.instantiate()
	var target_parent = get_tree().root.get_child(0)
	target_parent.add_child.call_deferred(profile_scene)
	profile_scene.hide()
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
	item_position_marker.position.x *= -1

	if current_equipment:
		current_equipment.handle_flip_direction()

func handle_jumping(delta: float):
	# Jump when on floor, double jump when not on floor and can double jump, wall jump when dragging and on wall
	if is_on_floor():
		velocity.y = -JUMP_STRENGTH
		return

	var double_jump = can_double_jump and not m_is_dragging and not is_on_floor() and double_jump_count < 1
	if double_jump:
		print("Double jump triggered")
		velocity.y = -JUMP_STRENGTH
		double_jump_count += 1
		return

	var wall_jump = can_wall_jump and m_is_dragging and is_on_wall()
	if wall_jump:
		print("Wall jump triggered")
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var normal = collision.get_normal()
			if normal.x == 0:
				continue

			velocity.y = -JUMP_STRENGTH
			velocity.x = -WALKING_SPEED if normal.x < 0 else WALKING_SPEED

			m_flip_sprite = not m_flip_sprite

			m_is_dragging = false
			m_disable_fall = false

		return

func handle_death():
	m_life=0
	apply_animation()
	set_physics_process(false)

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

	m_triggered_attack = true
	attack_timer.start()

func handle_equiped_item():
	if current_equipment == null:
		return

	if not current_equipment.equiped:
		return

	if current_equipment.in_use:
		current_equipment.stop_use()
		return

	current_equipment.start_use()

func toggle_current_item():
	if not current_equipment:
		return

	if current_equipment.equiped:
		current_equipment.unequip()
		return

	current_equipment.equip()

func handle_drag_wall() -> void:
	# Strangely, the documentation says that
	# normal.x < 0 is left, but it's actually right
	# here. I do not know why.
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		if normal.x == 0:
			continue

		var action_pressed = "right" if normal.x < 0 else "left"
		if Input.is_action_just_pressed(action_pressed):
			velocity.y = 0

		m_is_dragging = Input.is_action_pressed(action_pressed)
		if m_is_dragging:
			velocity.y = WALL_DRAG_FALL_SPEED
			m_disable_fall = true

		if Input.is_action_just_released(action_pressed):
			m_is_dragging = false
			m_disable_fall = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("fakedeath"):
		handle_death()
		return

	if can_wall_grab and is_on_wall() and not is_on_floor():
		handle_drag_wall()

	if Input.is_action_just_pressed("jump"):
		handle_jumping(delta)

	if Input.is_action_just_pressed("attack"):
		handle_attack()

	if Input.is_action_just_pressed("toggle_equiped_item"):
		toggle_current_item()

	if Input.is_action_just_pressed("use_equiped_item"):
		handle_equiped_item()


	handle_crouching()

	calc_horizontal_velocity(delta)
	apply_animation()

	if not m_disable_fall:
		velocity.y += delta * GRAVITY

	move_and_slide()

	if is_on_floor():
		double_jump_count = 0
