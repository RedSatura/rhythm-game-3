extends Node2D

@onready var conductor = $Conductor

func _ready():
	conductor.play_song()
