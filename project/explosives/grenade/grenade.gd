extends CharacterBody2D

@export var gravity: float
@export var max_bounces: int

@onready var _area := $Area2D

var _bounces: int = 0

func _physics_process(delta: float) -> void:
	
	# Move
	var old_velocity := velocity
	velocity.y += gravity * delta
	move_and_slide()
	
	# We need to keep track of the velocity before move_and_slide() because
	# on a collision, the component that should get bounced will be zero.
	
	# Bounce
	var bounced := false
	if is_on_floor() or is_on_ceiling():
		bounced = true
		velocity.y = -old_velocity.y
	if is_on_wall():
		bounced = true
		velocity.x = -old_velocity.x
	
	# Explode through bouncing
	if bounced:
		_bounces += 1
		if _bounces == max_bounces:
			_explode(null)
	
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
	Globals.spawn_explosion_at(position)
	queue_free()
