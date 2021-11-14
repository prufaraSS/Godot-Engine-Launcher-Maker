extends CheckBox
class_name LauncherCheckBox

func _pressed():
	get_tree().current_scene.changedSetting(text,pressed)
