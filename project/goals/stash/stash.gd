class_name Stash
extends TileMap

signal stash_destroyed


func _explode(_explosion: Explosion) -> void:
	Globals.save_obtained_stash()
	stash_destroyed.emit()
	queue_free()
