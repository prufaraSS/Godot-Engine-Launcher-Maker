extends Control
class_name LauncherRoot

const APPLICATION_PATH = "checksettings.exe"
const UNIQUE_NAME = "Check settings"
const SETTINGS_ROOT_PATHS = ["Container/LeftGrid","Container/RightGrid","Title"]

var settings : Dictionary
var settingsDynamic : Dictionary

func runApplication():
	saveSettings()
	OS.execute(APPLICATION_PATH,[],false)
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	get_tree().quit()

func _ready():
	settings = {}
	settingsDynamic = {}
	var f = File.new()
	if f.file_exists("res://settings.json"):
		f.open("res://settings.json",File.READ)
		var res = JSON.parse(f.get_as_text())
		if res.error == 0:
			settings = res.result
			settingsDynamic = settings
		else:
			ErrorManager.error(res.error)
		f.close()
	if settings.has("_unique_name") == true and settings.get("_unique_name") == UNIQUE_NAME:
		for i in SETTINGS_ROOT_PATHS:
			var root = get_node(i)
			for node in root.get_children():
				if node is launchButton and settings.has("_autostart"):
					node.set_timer(settings.get("_autostart"))
				elif node.get("text") != null and settings.has(node.get("text")):
					if node is BaseButton:
						node.pressed = settings.get(node.get("text"))
					elif node is Range or node.get("CLASSCODE") == 0:
						node.value = settings.get(node.get("text"))
					elif node.CLASSCODE == 1:
						node.set_importeditems(settings.get(node.get("text")))
	else:
		if !settings.empty():
			if settings.has("_unique_name") == false:
				ErrorManager.error("No unique name found, can't execute.\nhas('_unique_name') == false")
			elif settings.get("_unique_name") != UNIQUE_NAME:
				ErrorManager.error("Prevented an attempt to apply foreign settings.\n_unique_name != UNIQUE_NAME")
		else:
			saveSettings()

func changedSetting(Name:String,param):
	settingsDynamic[Name] = param

func saveSettings():
	settings = settingsDynamic
	settings["_unique_name"] = UNIQUE_NAME
	var f = File.new()
	f.open("res://settings.json",File.WRITE)
	f.store_string(to_json(settings))
	f.close()
