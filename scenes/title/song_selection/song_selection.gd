extends ScrollContainer

var files: Array = []

func _ready() -> void:
	check_songs()
	
func check_songs() -> void:
	#thanks hiulit and RedwanFox
	#https://gist.github.com/hiulit/772b8784436898fd7f942750ad99e33e
	var dir: DirAccess = DirAccess.open("user://songs")
	dir.list_dir_begin()
	
	var file_name: String = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			print("user://songs/" + file_name)
			var song_dir: DirAccess = DirAccess.open("user://songs/" + file_name)
			song_dir.list_dir_begin()
			
			var song_file_name: String = dir.get_next()
			while song_file_name != "":
				if song_dir.current_is_dir():
					pass
				else:
					print(song_file_name)
					if song_file_name.get_extension() != "msf":
						song_file_name = song_dir.get_next()
						
					files.append(song_dir.get_current_dir() + "/" + song_file_name)
					
				song_file_name = song_dir.get_next()
		else:
			SignalHandler.emit_signal("send_error", "File accessing error.")
		file_name = dir.get_next()
		
	print(files)
