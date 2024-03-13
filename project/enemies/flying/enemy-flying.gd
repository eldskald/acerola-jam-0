class_name EnemyFlying
extends CharacterBody2D

@export var amplitude: float
@export var period: float
@export var initial_phase: float
@export var explosion_launch: Vector2
@export var gravity: float

@onready var _anim: AnimationPlayer = $"%AnimationPlayer"
@onready var _sprite: Sprite2D = $"%Sprite2D"
@onready var _hurtbox: Area2D = $"%HurtBox"

var _current_phase: float = 0.0
var _is_dead: bool = false


func _ready():
	_anim.play("flying")
	_current_phase += initial_phase
	position.y += amplitude * sin((initial_phase / period) * TAU)


func _physics_process(delta):
	if not _is_dead:
		
		# Update position and velocity to make it move up and down in a senoid.
		_current_phase += delta
		if _current_phase >= period:
			_current_phase -= period
		velocity.y = -amplitude * cos((_current_phase / period) * TAU)
		move_and_slide()
		
		# Make it always face the player
		var player = Globals.get_player()
		if position.x - player.position.x <= 0.0:
			_sprite.scale.x = 1.0
		else:
			_sprite.scale.x = -1.0
			
	else:
		velocity.y += gravity * delta
		move_and_slide()
		if is_on_floor():
			queue_free()


func _explode(explosion: Explosion):
	if explosion.position.x - position.x <= 0.1:
		velocity.x = explosion_launch.x
	else:
		velocity.x = -explosion_launch.x * sign(explosion.position.x - position.x)
	velocity.y = explosion_launch.y
	_is_dead = true
	_hurtbox.monitoring = false
	_sprite.scale.x = sign(velocity.x)
	set_collision_mask_value(4, false)
	_anim.play("dead")


func _on_hurt_box_body_entered(body: Node2D):
	if body is Player:
		body.kill()
