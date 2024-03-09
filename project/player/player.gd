class_name Player
extends CharacterBody2D

@export_category("Basic Movement")
@export var speed: float
@export var acceleration: float
@export var air_acceleration: float
@export var friction: float
@export var air_friction: float
@export var gravity: float
@export var fall_speed: float

@export_category("Explosion Movement")
@export var vertical_launch: Vector2
@export var forward_launch: Vector2
@export var launch_pos_x_treshold: float
@export var launch_pos_y_treshold: float
@export var explosion_immunity_time: float

@export_category("Bomb throwing")
@export var mine_scene: PackedScene
@export var grenade_scene: PackedScene
@export var bomb_throw_cooldown: float
@export var launch_offset: Vector2
@export var mine_throw_speed: Vector2
@export var grenade_throw_speed_forward: Vector2
@export var grenade_throw_speed_down: Vector2

@onready var _bomb_throw_cooldown_timer: Timer = $BombThrowCooldown
@onready var _explosion_immunity_timer: Timer = $ExplosionImmunityTimer

var _facing: float = 1.0


func _physics_process(delta) -> void:
	_move(delta)
	_throw_bombs()


func _move(delta) -> void:
	var dir_input = _get_input_dir()
	
	# Update facing
	if dir_input != 0.0:
		_facing = dir_input
	
	# Horizontal movement
	if abs(velocity.x) < speed:
		if dir_input != 0.0:
			velocity.x = clampf(
				velocity.x + dir_input * _get_acceleration() * delta, -speed, speed
			)
		elif dir_input <= 0.0 and velocity.x > 0.0:
			velocity.x = clampf(
				velocity.x - _get_friction() * delta, 0.0, speed
			)
		elif dir_input >= 0.0 and velocity.x < 0.0:
			velocity.x = clampf(
				velocity.x + _get_friction() * delta, -speed, 0.0
			)
	else:
		velocity.x -= sign(velocity.x) * _get_friction() * delta
	
	# Vertical movement
	velocity.y = clampf(velocity.y + gravity * delta, -INF, fall_speed)
	
	move_and_slide()


func _throw_bombs():
	if not _bomb_throw_cooldown_timer.is_stopped():
		return
	
	if Input.is_action_just_pressed("throw_mine"):
		var mine = mine_scene.instantiate()
		mine.position = position + _facing * launch_offset
		mine.velocity.x = mine_throw_speed.x * _facing
		mine.velocity.y = mine_throw_speed.y
		Globals.get_level().add_child(mine)
		_bomb_throw_cooldown_timer.start(bomb_throw_cooldown)
	
	if Input.is_action_just_pressed("throw_grenade"):
		var grenade = grenade_scene.instantiate()
		grenade.position = position + _facing * launch_offset
		if Input.is_action_pressed("look_down") and not is_on_floor():
			grenade.velocity = grenade_throw_speed_down
		else:
			grenade.velocity.x = grenade_throw_speed_forward.x * _facing
			grenade.velocity.y = grenade_throw_speed_forward.y
		Globals.get_level().add_child(grenade)
		_bomb_throw_cooldown_timer.start(bomb_throw_cooldown)


func _explode(explosion: Explosion) -> void:
	if not _explosion_immunity_timer.is_stopped():
		return
	if (
		explosion.position.y > position.y + launch_pos_y_treshold
		and abs(explosion.position.x - position.x) < launch_pos_x_treshold
	):
		velocity = vertical_launch
	else:
		velocity.x = -forward_launch.x * sign(explosion.position.x - position.x)
		velocity.y = forward_launch.y
	_explosion_immunity_timer.start(explosion_immunity_time)


func _get_input_dir() -> float:
	return (
		Input.get_action_strength("move_right")
		-Input.get_action_strength("move_left")
	)


func _get_acceleration() -> float:
	if is_on_floor():
		return acceleration
	else:
		return air_acceleration


func _get_friction() -> float:
	if is_on_floor():
		return friction
	else:
		return air_friction
