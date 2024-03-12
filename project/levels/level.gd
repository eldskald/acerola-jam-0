class_name Level
extends Node2D

@onready var _player: Player
@onready var _camera: Camera2D = $Camera2D
@onready var _stash: Node

var camera_target: Node2D
var _stash_state: bool = true


func _ready():
	camera_target = _player
	if not _stash_state and _stash:
		_stash.queue_free()


func _physics_process(_delta):
	_camera.position = camera_target.position


func _load_data(data: Dictionary):
	_stash_state = not data.get("stash", false)
