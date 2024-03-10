extends Node

@export var _explosion_scene: PackedScene


func get_level() -> Level:
	return get_tree().get_nodes_in_group(Level._GROUP)[0]


func spawn_explosion_at(point: Vector2) -> Explosion:
	var explosion = _explosion_scene.instantiate()
	explosion.position = point
	get_level().call_deferred("add_child", explosion)
	return explosion
