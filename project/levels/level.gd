class_name Level
extends Node2D

@onready var _player: Player = $Player
@onready var _camera: Camera2D = $Camera2D
@onready var _stash: Stash = $Stash
@onready var _stash_explosion: BigExplosionAnimation = $StashExplosion
@onready var _message: Label = $"%MessageLabel"
@onready var _message_timer: Timer = $"%MessageLifetime"
@onready var _level_complete_timer: Timer = $"%LevelCompleteTimer"
@onready var _player_died_timer: Timer = $"%PlayerDiedTimer"

var camera_target: Node2D
var _stash_state: bool = true


func _ready() -> void:
	camera_target = _player
	if not _stash_state and _stash:
		_stash.queue_free()


func _physics_process(_delta) -> void:
	_camera.position = camera_target.position


func _load_data(data: Dictionary) -> void:
	_stash_state = not data.get("stash", false)


func _set_message(message: String) -> void:
	_message.text = message
	_message.show()
	_message_timer.start()


func _on_stash_destroyed() -> void:
	_stash_explosion.play()
	_set_message("GNOME STASH DESTROYED")
	Globals.save_obtained_stash()


func _on_fortress_destroyed() -> void:
	_set_message("LEVEL COMPLETE")
	_level_complete_timer.start()


func _on_player_player_died():
	_player_died_timer.start()


func _on_message_lifetime_timeout() -> void:
	_message.hide()


func _on_level_complete_timer_timeout() -> void:
	Globals.next_level()


func _on_player_died_timer_timeout() -> void:
	if _level_complete_timer.is_stopped():
		Globals.reset_level()
