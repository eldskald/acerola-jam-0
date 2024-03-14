extends Node

@export var _explosion_scene: PackedScene
@export var _levels: Array[PackedScene]
@export var _transition_scene: PackedScene
@export var _intro: PackedScene
@export var _outro: PackedScene

@onready var _main = get_node("/root/Main")
@onready var _select_sound: AudioStreamPlayer = $Select
@onready var _bounce_sound: AudioStreamPlayer = $Bounce
@onready var _explosion_sounds: Array[AudioStreamPlayer] = [
	$Explosion1, $Explosion2, $Explosion3, $Explosion4
]
@onready var _throw_sounds: Array[AudioStreamPlayer] = [
	$Throw1, $Throw2, $Throw3, $Throw4
]
@onready var _explosion_time_cooldown: Timer = $ExplosionTimeCooldown
@onready var _intro_outro_bgm: AudioStreamPlayer = $IntroOutroMusic
@onready var _action_bgm: AudioStreamPlayer = $ActionMusic

var _current_level: int = 0
var _stashes: Array[bool] = []


func _ready() -> void:
	for i in _levels.size():
		_stashes.append(false)


func get_level() -> Node:
	return get_tree().get_nodes_in_group("level")[0]


func get_player() -> Node:
	return get_tree().get_nodes_in_group("player")[0]


func spawn_explosion_at(point: Vector2) -> Node:
	var explosion = _explosion_scene.instantiate()
	explosion.position = point
	get_level().call_deferred("add_child", explosion)
	play_explosion_sound(randi() % _explosion_sounds.size())
	return explosion


func play_random_throw_sound() -> void:
	for player in _throw_sounds:
		player.stop()
	_throw_sounds[randi() % _throw_sounds.size()].play()


func play_throw_sound(id: int) -> void:
	for player in _throw_sounds:
		player.stop()
	_throw_sounds[id].play()


func play_bounce_sound() -> void:
	_bounce_sound.play()


func play_explosion_sound(id: int) -> void:
	if not _explosion_time_cooldown.is_stopped():
		return
	for player in _explosion_sounds:
		player.stop()
	_explosion_sounds[id].play()


func play_select_sound() -> void:
	_select_sound.play()


func play_intro_outro_music() -> void:
	_action_bgm.stop()
	_intro_outro_bgm.play()


func play_action_music() -> void:
	_intro_outro_bgm.stop()
	_action_bgm.play()


func stop_music() -> void:
	_action_bgm.stop()
	_intro_outro_bgm.stop()


func go_to_intro() -> void:
	_main.change_scene(_intro)


func go_to_outro() -> void:
	_main.change_scene(_outro)


func go_to_level(level: int) -> void:
	_current_level = level
	_main.change_scene(
		_levels[level - 1],
		{stash = _stashes[level - 1]},
	)


func reset_level() -> void:
	_main.change_scene(
		_transition_scene,
		{to_level = _current_level},
	)


func next_level() -> void:
	_current_level += 1
	if _current_level <= _levels.size():
		_main.change_scene(
			_transition_scene,
			{to_level = _current_level},
		)
	else:
		go_to_outro()
		play_intro_outro_music()


func save_obtained_stash() -> void:
	_stashes[_current_level - 1] = true
