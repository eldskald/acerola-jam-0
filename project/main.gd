class_name Main
extends Node2D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Globals.go_to_intro()


func change_scene(scene: PackedScene, load_data: Dictionary = {}) -> void:
	for child in get_children():
		child.queue_free()
	var new = scene.instantiate()
	if new.has_method("_load_data"):
		new.call("_load_data", load_data)
	add_child(new)
