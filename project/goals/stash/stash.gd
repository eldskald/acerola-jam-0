class_name Stash
extends TileMap

signal stash_obtained


func _explode(explosion: Explosion) -> void:
	Globals.save_obtained_stash()
	stash_obtained.emit()
	queue_free()
