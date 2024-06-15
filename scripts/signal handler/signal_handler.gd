extends Node

#song validator
signal send_song_to_validator(path)
signal song_validated

#file statuses
signal song_saved

#send initial song data
signal get_song_length(length)
signal get_song_offset(offset)

#send current song data
signal get_song_position(position)

#other data
signal get_hitspot_position(position)

signal beat_occured(current_beat)
signal measure_occured

signal note_hit(grade)

signal note_missed

#errors
signal send_error(error)

#messages
signal send_message(message)

#status label (title screen)
signal clear_status_label

#title screen
signal reset_to_defaults

#song editor
signal update_editor_line_color(line, color: Color)
