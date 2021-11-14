extends Button
class_name saveButton

func _ready():
	connect("pressed",get_tree().current_scene,"saveSettings")
