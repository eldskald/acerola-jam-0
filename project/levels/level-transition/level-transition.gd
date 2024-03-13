class_name LevelTransition
extends CanvasLayer

const MESSAGES := [
	"If you're not getting hurt by your own bombs, you're not cooking them right.",
	"Anger is fuel. It can do work or set your house on fire. Your choice.",
	"Gnome alchemists try to make gold and cry when they get an explosion, they don't know what's actually valuable.",
	"Now they blew it!",
	"There are many forms of power but if you have willpower, you can get all others.",
	"Controlling your emotions isn't about bottling them up, it's about releasing them the right way.",
	"The secret to cooking bombs is to put some love in it.",
]

@onready var _label: Label = $Label
@onready var _timer: Timer = $Timer

var _to_level: int = 0


func _ready() -> void:
	_label.text = MESSAGES[randi() % (MESSAGES.size())]


func _physics_process(_delta) -> void:
	if Input.is_anything_pressed() and _timer.is_stopped():
		Globals.go_to_level(_to_level)
		Globals.play_select_sound()


func _load_data(data: Dictionary) -> void:
	_to_level = data.to_level


