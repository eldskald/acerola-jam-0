extends CharacterBody2D

@export var SPEED: float
@export var ACCELERATION: float
@export var AIR_ACCELERATION: float
@export var FRICTION: float
@export var AIR_FRICTION: float
@export var GRAVITY: float
@export var FALL_SPEED: float


func _physics_process(delta) -> void:
	var dir_input = _get_input_dir()
	if abs(velocity.x) < SPEED:
		if dir_input != 0.0:
			velocity.x = clampf(
				velocity.x + dir_input * _get_acceleration() * delta, -SPEED, SPEED
			)
		elif dir_input <= 0.0 and velocity.x > 0.0:
			velocity.x = clampf(
				velocity.x - _get_friction() * delta, 0.0, SPEED
			)
		elif dir_input >= 0.0 and velocity.x < 0.0:
			velocity.x = clampf(
				velocity.x + _get_friction() * delta, -SPEED, 0.0
			)
	else:
		velocity.x -= sign(velocity.x) * _get_friction() * delta
	
	velocity.y = clampf(velocity.y + GRAVITY * delta, -INF, FALL_SPEED)
	
	move_and_slide()


func _get_input_dir() -> float:
	return (
		Input.get_action_strength("move_right")
		-Input.get_action_strength("move_left")
	)


func _get_acceleration() -> float:
	if is_on_floor():
		return ACCELERATION
	else:
		return AIR_ACCELERATION


func _get_friction() -> float:
	if is_on_floor():
		return FRICTION
	else:
		return AIR_FRICTION
