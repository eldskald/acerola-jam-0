class_name EnemyGrounded
extends CharacterBody2D

enum Facing { LEFT, RIGHT }

@export var initial_facing: Facing
@export var speed: float
@export var gravity: float
@export var explosion_launch: Vector2

@onready var _anim: AnimationPlayer = $"%AnimationPlayer"
@onready var _sprite: Sprite2D = $"%Sprite2D"
@onready var _hurtbox: Area2D = $"%HurtBox"
@onready var _left_edge_detector: Area2D = $"%EdgeDetectorLeft"
@onready var _right_edge_detector: Area2D = $"%EdgeDetectorRight"

var _is_dead: bool = false
var _facing: float = 1.0


func _ready():
	_anim.play("moving")
	_facing = 1.0 if initial_facing == Facing.RIGHT else -1.0
	velocity = Vector2(speed * _facing, 0.0)


func _physics_process(delta):
	if position.y >= 400:
		queue_free()
		return
	
	if not _is_dead:
		if (
			(is_on_wall() and get_wall_normal().x * velocity.x <= 0.0)
			or _left_edge_detector.get_overlapping_bodies().is_empty()
			or _right_edge_detector.get_overlapping_bodies().is_empty()
		):
			_facing *= -1
		_sprite.scale.x = _facing
		velocity.x = _facing * speed
		move_and_slide()
	else:
		velocity.y += gravity * delta
		_sprite.scale.x = _facing
		move_and_slide()
		if is_on_floor():
			queue_free()


func _explode(explosion: Explosion):
	if explosion.position.x - position.x <= 0.1:
		velocity.x = explosion_launch.x * (-_facing)
	else:
		velocity.x = -explosion_launch.x * sign(explosion.position.x - position.x)
	velocity.y = explosion_launch.y
	_facing = sign(velocity.x)
	_is_dead = true
	_hurtbox.monitoring = false
	set_collision_mask_value(4, false)
	_anim.play("dead")


func _on_hurt_box_body_entered(body: Node2D):
	if body is Player:
		body.kill()
