class_name Explosion
extends Area2D

@onready var _anim: AnimationPlayer = $AnimationPlayer

var launch_up: bool = false


func _ready() -> void:
	_anim.play("explosion")


func _on_body_entered(body) -> void:
	if body.has_method("_explode"):
		body.call("_explode", self)
