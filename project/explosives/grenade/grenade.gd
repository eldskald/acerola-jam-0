extends CharacterBody2D

@export var gravity: float
@export var max_bounces: int

@onready var _area: Area2D = $Area2D
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim: AnimationPlayer = $AnimationPlayer

var launch_up: bool = false

var _bounces: int = 0


func _ready():
	_sprite.frame = randi() % 4
	_anim.play("roll")

func _physics_process(delta: float) -> void:
	if position.y >= 400:
		queue_free()
		return
	
	if abs(velocity.x) <= 0.1:
		_sprite.flip_h = false
		_anim.speed_scale = 1.0
	else:
		_sprite.flip_h = sign(velocity.x) < 0.0
		_anim.speed_scale = sign(velocity.x)
	
	# Move
	velocity.y += gravity * delta
	var old_velocity := velocity
	var old_position := position
	move_and_slide()
	
	# We need to keep track of the velocity and position before move_and_slide()
	# because on a collision, the velocity's component that should get bounced
	# will be zero and the position will be different so the maximum height will
	# change, so we need to restore it to how it was but with velocity bounced.
	
	# Bounce
	var bounced := false
	if is_on_floor() or is_on_ceiling():
		bounced = true
		velocity.y = -old_velocity.y
		position.y = old_position.y
	if is_on_wall():
		bounced = true
		velocity.x = -old_velocity.x
	
	# Explode through bouncing
	if bounced:
		_bounces += 1
		if _bounces == max_bounces:
			_explode(null)
		else:
			Globals.play_bounce_sound()
	
	# Explode through contact
	for body in _area.get_overlapping_bodies():
		if (
			body != self
			and not is_queued_for_deletion()
		):
			if (
				(body is Player and _bounces >= 1)
				or not body is Player
			):
				_explode(null)


func _explode(_explosion: Explosion) -> void:
	Globals.spawn_explosion_at(position, launch_up)
	queue_free()
