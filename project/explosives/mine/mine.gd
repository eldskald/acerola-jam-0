extends CharacterBody2D

@export_category("Physics")
@export var gravity: float

@export_category("Explosion")
@export var detection_threshold: float

@onready var _area: Area2D = $Area2D


func _physics_process(delta: float) -> void:
	
	# Check for explosion
	if is_on_floor():
		for body in _area.get_overlapping_bodies():
			if (
				body != self
				and not is_queued_for_deletion()
			):
				if (
					(
						not body.get_collision_layer_value(3)
						and abs(body.position.x - position.x) <= detection_threshold
					) or body.get_collision_layer_value(3)
				):
					_explode(null)
	
	# Physics
	if is_on_floor():
		velocity = Vector2.ZERO
	else:
		velocity.y += gravity * delta
	move_and_slide()


func _explode(_explosion: Explosion):
	Globals.spawn_explosion_at(position)
	queue_free()
