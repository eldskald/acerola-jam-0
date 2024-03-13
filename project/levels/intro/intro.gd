class_name Intro
extends CanvasLayer

const MESSAGE_1 := """
Years ago, a poor goblin was born. His body was weak, and his legs were small and twisted.
He couldn't walk.
"""

const MESSAGE_2 := """
"Monster! Aberration!" - cried the other goblin children.
He always got mad and would claw and bite back. He was reckless and had a short fuse.
"""

const MESSAGE_3 := """
What he lacked in physical strength, he made up for with sheer will.
In early youth, he learned to channel his anger into constructive goals.
"""

const MESSAGE_4 := """
When the gnomes attacked, he knew what to do. Unfortunately, the others wouldn't let he join the war due to his disabilities.
"""

const MESSAGE_5 := """
He didn't care. His legs couldn't stop him, goblins couldn't stop him, gnomes won't either.
Determined, he is about to show what an actual butt kicking looks like!
"""

const MESSAGES := [null, MESSAGE_1, MESSAGE_2, MESSAGE_3, MESSAGE_4, MESSAGE_5]

@onready var _title: Label = $GameTitle
@onready var _credits: Label = $Credits
@onready var _label: Label = $Label
@onready var _timer: Timer = $WaitTimer
@onready var _first_timer: Timer = $FirstTimer
@onready var _last_timer: Timer = $LastTimer
@onready var _anim: AnimationPlayer = $AnimationPlayer

var _state: int = 0


func _physics_process(_delta):
	if (
		Input.is_anything_pressed()
		and _timer.is_stopped()
		and _first_timer.is_stopped()
		and _state <= 6
	):
		match _state:
			0:
				Globals.play_explosion_sound(0)
				_title.hide()
				_credits.hide()
				_first_timer.start()
			6:
				Globals.play_explosion_sound(0)
				_label.hide()
				_last_timer.start()
			_:
				Globals.play_select_sound()
				_label.text = MESSAGES[_state]
				_anim.stop()
				_anim.play("show_text")
				_timer.start()
		_state += 1


func _on_first_timer_timeout():
	_label.text = MESSAGE_1
	_anim.stop()
	_anim.play("show_text")
	_timer.start()
	_state += 1


func _on_last_timer_timeout():
	Globals.go_to_level(1)
