class_name Outro
extends CanvasLayer


func _ready():
	var count = Globals.get_obtained_stashes()
	var total = Globals.get_total_stashes()
	$StashCount.text = "You got " + str(count) + "/" + str(total) + " gnome stashes!"
