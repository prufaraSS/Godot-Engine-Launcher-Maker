extends Control
class_name LauncherMain

##Path to the executable for which launcher is meant for.
@export_global_file("*.exe") var executable:String

##Arguments for the executable.
@export var launch_arguments :PackedStringArray

##Path for the config to be saved.
@export_global_dir var settings_directory := "res://"

##Launch executable with debug console.
@export var launch_console := false


class handle:
	var node_class:String
	var getter:Callable
	var setter:Callable
	func _init(c:String, f=null, s:=func(): return):
		node_class = c
		if f is String:
			getter = func(i): return i.get(f)
			setter = func(i,v): i.set(f,v)
		elif f is Callable:
			getter = f
			setter = s

var classes :Array[handle] = [
	handle.new("Range","value"),
	handle.new("OptionButton","selected"),
	handle.new("ColorPickerButton",\
		func(i): return i.color.to_html(),\
		func(i,v): i.color = Color.from_string(v,Color.BLACK)
	),
	handle.new("LineEdit","text"),
	handle.new("TextEdit","text"),
	handle.new("BaseButton","button_pressed")
]

func get_structure() -> Dictionary:
	return {
		"settings": {},
		"properties": {
			"autosave": false,
			"autoproceed": false
		}
	}

func save():
	var file := FileAccess.open(settings_directory + "/settings.json",FileAccess.WRITE)
	var structure := get_structure()
	structure.properties.autosave = get_tree()\
		.get_first_node_in_group("autosave").button_pressed
	structure.properties.autoproceed = get_tree()\
		.get_first_node_in_group("autoproceed").button_pressed
	for item in get_tree().get_nodes_in_group("keep"):
		structure.settings[item.name] = get_handle(item).getter.call(item)
	file.store_string(JSON.stringify(structure))

func proceed():
	OS.create_process(executable,launch_arguments,launch_console)

func get_handle(node:Node) -> handle:
	for item in classes:
		if node.is_class(item.node_class):
			return item
	push_error("foundnt " + node.get_class())
	return null

func init_file():
	var file := FileAccess.open(settings_directory + "/settings.json",FileAccess.WRITE)
	var structure := get_structure()
	file.store_string(JSON.stringify(structure))
	file.close()

func _ready():
	var file := FileAccess.get_file_as_string(settings_directory + "/settings.json")
	if !file:
		init_file()
		return
	var data :Dictionary = JSON.parse_string(file)
	
	for item in get_tree().get_nodes_in_group("keep"):
		if !data.settings.has(item.name): return
		get_handle(item).setter.call(item,data.settings[item.name])
	
	var autosave := get_tree().get_first_node_in_group("autosave")
	var autoproceed := get_tree().get_first_node_in_group("autoproceed")
	autosave.button_pressed = data.properties.autosave
	autoproceed.button_pressed = data.properties.autoproceed
	if autoproceed.button_pressed:
		var countdown := Timer.new()
		var closing := Timer.new()
		countdown.wait_time = 1
		closing.wait_time = 3
		autoproceed.text += " (3)"
		countdown.timeout.connect(func():
			autoproceed.text = autoproceed.text.left(autoproceed.text.length() -2)
			autoproceed.text += str(int(closing.time_left)) + ")"
		)
		closing.timeout.connect(func():
			proceed()
			quit()
		)
		add_child(countdown)
		add_child(closing)
		countdown.start()
		closing.start()
		autoproceed.pressed.connect(func():
			countdown.stop()
			closing.stop()
			autoproceed.text = autoproceed.text.left(autoproceed.text.length() -3)
		, Object.CONNECT_ONE_SHOT)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if !get_tree()\
			.get_first_node_in_group("autosave")\
			.button_pressed:
				Exit.popup_centered()
		else:
			save()
			quit()

func quit():
	get_tree().quit()
