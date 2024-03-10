class_name PlayerSprite
extends Sprite2D

var _state_animations: Dictionary = {
	Player.State.STANDING: "standing",
	Player.State.MOVING: "moving",
	Player.State.AIRBORNE: "airborne",
	Player.State.EXPLODED: "exploded",
	Player.State.DEAD: "dead",
}

@onready var _player: Player = get_parent() as Player
@onready var _anim: AnimationPlayer = $"%AnimationPlayer"
@onready var _top_particles: Array = [
	$"%TopParticle1", $"%TopParticle2", $"%TopParticle3",
]
@onready var _bot_particles: Array = [
	$"%BotParticle1", $"%BotParticle2", $"%BotParticle3",
]


func _process(_delta):
	if _player.get_state() in [Player.State.EXPLODED, Player.State.DEAD]:
		scale.x = 1.0
	else:
		scale.x = _player.get_facing()


func _get_random_exploded_frame():
	frame = 5 + randi() % 3


func _set_bottom_particles(value: bool):
	for emitter in _bot_particles:
		emitter.emitting = value


func _set_top_particles(value: bool):
	for emitter in _top_particles:
		emitter.emitting = value


func _on_player_state_changed(new_state):
	_anim.play(_state_animations[new_state])
