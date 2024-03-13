class_name Player
extends CharacterBody2D

signal state_changed(new_state: State)
signal player_died

enum State { STANDING, MOVING, AIRBORNE, EXPLODED, DEAD }

@export_category("Basic Movement")
@export var speed: float
@export var acceleration: float
@export var air_acceleration: float
@export var friction: float
@export var air_friction: float
@export var gravity: float
@export var fall_speed: float
@export var death_float_speed: Vector2

@export_category("Explosion Movement")
@export var vertical_launch: Vector2
@export var forward_launch: Vector2
@export var launch_dir_pos_x_treshold: float
@export var explosion_immunity_time: float

@export_category("Bomb throwing")
@export var mine_scene: PackedScene
@export var grenade_scene: PackedScene
@export var bomb_throw_cooldown: float
@export var launch_offset: Vector2
@export var mine_throw_speed: Vector2
@export var grenade_throw_speed_forward: Vector2
@export var grenade_throw_speed_down: Vector2

@onready var _spike_detector: Area2D = $SpikeDetector
@onready var _bomb_throw_cooldown_timer: Timer = $BombThrowCooldown
@onready var _explosion_immunity_timer: Timer = $ExplosionImmunityTimer
@onready var _platform_drop_timer: Timer = $PlatformDropTimer

var _facing: float = 1.0
var _state: State = State.STANDING


func _physics_process(delta) -> void:
	if _state != State.DEAD:
		_move(delta)
		_throw_bombs()
	else:
		move_and_slide()


func get_facing() -> float:
	return _facing


func get_state() -> State:
	return _state


func kill() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(2, false)
	set_collision_mask_value(5, false)
	_spike_detector.set_deferred("monitoring", false)
	_set_state(State.DEAD)
	velocity = death_float_speed
	Globals.spawn_explosion_at(position)
	player_died.emit()


func _set_state(new_state: State) -> void:
	if new_state != _state:
		state_changed.emit(new_state)
		_state = new_state


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
	if Input.is_action_just_pressed("look_down"):
		_platform_drop_timer.start()
		set_collision_mask_value(5, false)
	
	move_and_slide()
	
	# Move states
	if is_on_floor() and abs(velocity.x) <= 0.1:
		_set_state(State.STANDING)
	elif is_on_floor():
		_set_state(State.MOVING)
	elif not is_on_floor() and _state != State.EXPLODED:
		_set_state(State.AIRBORNE)


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
		if _state == State.EXPLODED:
			_set_state(State.AIRBORNE)
		Globals.play_random_throw_sound()
	
	if Input.is_action_just_pressed("throw_grenade"):
		var grenade = grenade_scene.instantiate()
		grenade.position = position
		if Input.is_action_pressed("look_down") and not is_on_floor():
			grenade.velocity = grenade_throw_speed_down
		else:
			grenade.position += _facing * launch_offset
			grenade.velocity.x = grenade_throw_speed_forward.x * _facing
			grenade.velocity.y = grenade_throw_speed_forward.y
		Globals.get_level().add_child(grenade)
		_bomb_throw_cooldown_timer.start(bomb_throw_cooldown)
		if _state == State.EXPLODED:
			_set_state(State.AIRBORNE)
		Globals.play_random_throw_sound()


func _explode(explosion: Explosion) -> void:
	if not _explosion_immunity_timer.is_stopped() or _state == State.DEAD:
		return
	if abs(explosion.position.x - position.x) < launch_dir_pos_x_treshold:
		velocity = vertical_launch
	else:
		if explosion.position.x - position.x <= 0.1:
			velocity.x = forward_launch.x * (-_facing)
		else:
			velocity.x = -forward_launch.x * sign(explosion.position.x - position.x)
		velocity.y = forward_launch.y
	_explosion_immunity_timer.start(explosion_immunity_time)
	_set_state(State.EXPLODED)


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


func _on_platform_drop_timeout() -> void:
	set_collision_mask_value(5, true)


func _on_spike_detector_body_entered(_body) -> void:
	kill()
