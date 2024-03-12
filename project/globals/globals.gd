extends Node

@export var _explosion_scene: PackedScene
@export var _levels: Array[PackedScene]

@onready var _main: Main = get_node("/root/Main")

var _current_level: int = 0
var _stashes: Array[bool] = []


func _ready():
	for i in _levels.size():
		_stashes.append(false)


func get_level():
	return get_tree().get_nodes_in_group("level")[0]


func spawn_explosion_at(point: Vector2):
	var explosion = _explosion_scene.instantiate()
	explosion.position = point
	get_level().call_deferred("add_child", explosion)
	return explosion


func reset_level() -> void:
	_main.change_scene(
		_levels[_current_level],
		{stash = _stashes[_current_level]},
	)


func next_level() -> void:
	_current_level += 1
	if _current_level < _levels.size():
		_main.change_scene(
			_levels[_current_level],
			{stashes = _stashes[_current_level]},
		)


func save_obtained_stash() -> bool:
	if not _stashes[_current_level]:
		_stashes[_current_level] = true
		return true
	return false
