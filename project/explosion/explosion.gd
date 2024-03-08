class_name Explosion
extends Area2D


func _ready() -> void:
	$AnimationPlayer.play("explosion")


func _on_body_entered(body) -> void:
	if body.has_method("_explode"):
		body.call("_explode", self)
