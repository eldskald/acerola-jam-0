class_name Fortress
extends StaticBody2D

signal fortress_destroyed

@onready var _explosion_anim: BigExplosionAnimation = $BigExplosionAnimation
@onready var _whole: Sprite2D = $Whole
@onready var _destroyed: Sprite2D = $Destroyed
@onready var _brick_particles_hit_1: Array[GPUParticles2D] = [
	$Particles1Hit1, $Particles2Hit1, $Particles3Hit1, $Particles4Hit1
]
@onready var _brick_particles_hit_2: Array[GPUParticles2D] = [
	$Particles1Hit2, $Particles2Hit2, $Particles3Hit2, $Particles4Hit2
]
@onready var _brick_particles_hit_3: Array[GPUParticles2D] = [
	$Particles1Hit3, $Particles2Hit3, $Particles3Hit3, $Particles4Hit3
]

var _hits: int = 0


func _explode(_explosion: Explosion) -> void:
	if _hits >= 3:
		return
	_hits += 1
	match _hits:
		1:
			for emitter in _brick_particles_hit_1:
				emitter.emitting = true
		2:
			for emitter in _brick_particles_hit_2:
				emitter.emitting = true
		3:
			for emitter in _brick_particles_hit_3:
				emitter.emitting = true
			fortress_destroyed.emit()
			_explosion_anim.play()
			_whole.hide()
			_destroyed.show()
