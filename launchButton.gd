extends Button
class_name launchButton

var activateAfterTimer := false setget set_timer
var buttontext := ""
var time = 5

func set_timer(param):
	activateAfterTimer = param
	if param == true:
		buttontext = text
		var t = Timer.new()
		t.wait_time = 1
		t.one_shot = false
		add_child(t)
		t.start()
		t.connect("timeout",self,"timeout")
	else:
		time = 5
		if get_child_count() != 0:
			for i in get_children():
				if i is Timer:
					i.stop()
					i.queue_free()

func _ready():
	buttontext = text

func timeout():
	text = buttontext + " (" + str(time) + ")"
	time -= 1
	if time < 0:
		_pressed()

func _pressed():
	get_tree().current_scene.runApplication()
