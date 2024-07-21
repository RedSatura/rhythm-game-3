extends Node

#song validator
signal send_song_to_validator(path: String)
signal song_validated

#song statuses
signal song_ended

#file statuses
signal song_saved

#send initial song data
signal get_song_length(length: int)
signal get_song_offset(offset: float)

#send current song data
signal get_song_position(position: float)

#other data
signal get_hitspot_position(position: Vector2)

signal beat_occured(current_beat: int)
signal measure_occured

signal note_hit(grade: String)

signal note_missed

#errors
signal send_error(error: String)

#messages
signal send_message(message: String)

#status label (title screen)
signal clear_status_label

#title screen
signal reset_to_defaults

#song editor
signal update_editor_line_color(line: int, color: Color)

#themes
signal change_theme(theme: Theme)

#region title_screen
signal toggle_show_title_screen_options(status: bool)
#endregion

