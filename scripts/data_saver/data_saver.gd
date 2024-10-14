extends Node

const save_path: String = ""


func _ready() -> void:
	if DirAccess.dir_exists_absolute("user://save_data"):
		pass
	else:
		DirAccess.make_dir_absolute("user://save_data")
		
	load_data()
	
#Get game data from the GlobalData autoload script
func save_data() -> void:
	var config: ConfigFile = ConfigFile.new()
	
	config.set_value("GlobalSettings", "theme", GlobalData.global_settings["theme"])
	config.set_value("GlobalSettings", "theme_name", GlobalData.global_settings["theme_name"])
	config.set_value("GlobalSettings", "fullscreen", GlobalData.global_settings["fullscreen"])
	
	config.set_value("Keybinds", "lane_left_1", GlobalData.global_settings["key_lane_left_1"])
	config.set_value("Keybinds", "lane_center_left_1", GlobalData.global_settings["key_lane_center_left_1"])
	config.set_value("Keybinds", "lane_center_right_1", GlobalData.global_settings["key_lane_center_right_1"])
	config.set_value("Keybinds", "lane_right_1", GlobalData.global_settings["key_lane_right_1"])
	config.set_value("Keybinds", "pause", GlobalData.global_settings["key_pause"])
	config.set_value("Keybinds", "restart", GlobalData.global_settings["key_restart"])
	
	config.set_value("Audio", "master_volume", GlobalData.global_settings["master_volume"])
	
	config.set_value("Gameplay", "scroll_speed", GlobalData.global_settings["scroll_speed"])
	config.set_value("Gameplay", "upscroll", GlobalData.global_settings["upscroll"])
	
	var error: int = config.save("user://save_data/game_data.cfg")
	
	if error != OK:
		SignalHandler.emit_signal("send_error", "Error saving game save file! Error: %s" % error)
		return
	
#Loaded data should be sent to the GlobalData autoload script! 
func load_data() -> void:
	if FileAccess.file_exists("user://save_data/game_data.cfg"):
		var config: ConfigFile = ConfigFile.new()
		
		var error: int = config.load("user://save_data/game_data.cfg")
		
		if error != OK:
			SignalHandler.emit_signal("send_error", "Error loading game save file! Error: %s" % error)
			return
		else:
			GlobalData.global_settings["theme"] = config.get_value("GlobalSettings", "theme")
			GlobalData.global_settings["theme_name"] = config.get_value("GlobalSettings", "theme_name")
			GlobalData.global_settings["fullscreen"] = config.get_value("GlobalSettings", "fullscreen")
			
			GlobalData.global_settings["key_lane_left_1"] = config.get_value("Keybinds", "lane_left_1")
			GlobalData.global_settings["key_lane_center_left_1"] = config.get_value("Keybinds", "lane_center_left_1")
			GlobalData.global_settings["key_lane_center_right_1"] = config.get_value("Keybinds", "lane_center_right_1")
			GlobalData.global_settings["key_lane_right_1"] = config.get_value("Keybinds", "lane_right_1")
			GlobalData.global_settings["key_pause"] = config.get_value("Keybinds", "pause")
			GlobalData.global_settings["key_restart"] = config.get_value("Keybinds", "restart")
			
			GlobalData.global_settings["master_volume"] = config.get_value("Audio", "master_volume", 1.0)
			
			GlobalData.global_settings["scroll_speed"] = config.get_value("Gameplay", "scroll_speed", 1.0)
			GlobalData.global_settings["upscroll"] = config.get_value("Gameplay", "upscroll", false)
			
			#im sorry
			var key_scancode_1: InputEventKey = InputEventKey.new()
			key_scancode_1.set_keycode(GlobalData.global_settings["key_lane_left_1"])
			InputMap.action_erase_events("lane_left_1")
			InputMap.action_add_event("lane_left_1", key_scancode_1)
			var key_scancode_2: InputEventKey = InputEventKey.new()
			key_scancode_2.set_keycode(GlobalData.global_settings["key_lane_center_left_1"])
			InputMap.action_erase_events("lane_center_left_1")
			InputMap.action_add_event("lane_center_left_1", key_scancode_2)
			var key_scancode_3: InputEventKey = InputEventKey.new()
			key_scancode_3.set_keycode(GlobalData.global_settings["key_lane_center_right_1"])
			InputMap.action_erase_events("lane_center_right_1")
			InputMap.action_add_event("lane_center_right_1", key_scancode_3)
			var key_scancode_4: InputEventKey = InputEventKey.new()
			key_scancode_4.set_keycode(GlobalData.global_settings["key_lane_right_1"])
			InputMap.action_erase_events("lane_right_1")
			InputMap.action_add_event("lane_right_1", key_scancode_4)
			var key_scancode_5: InputEventKey = InputEventKey.new()
			key_scancode_5.set_keycode(GlobalData.global_settings["key_pause"])
			InputMap.action_erase_events("pause")
			InputMap.action_add_event("pause", key_scancode_5)
			var key_scancode_6: InputEventKey = InputEventKey.new()
			key_scancode_6.set_keycode(GlobalData.global_settings["key_restart"])
			InputMap.action_erase_events("restart")
			InputMap.action_add_event("restart", key_scancode_6)
