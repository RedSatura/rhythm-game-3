extends Node2D

@export var boss_health = 1000:
	set(value):
		boss_health = value
		healthbar.value = boss_health

@onready var sprite = $BossSprite
@onready var healthbar = $BossHealthbar

func _ready():
	SignalHandler.connect("note_hit", Callable(self, "note_hit"))
	healthbar.max_value = boss_health
	healthbar.value = healthbar.max_value

func _physics_process(_delta):
	sprite.rotation_degrees += 1

func note_hit(note_damage):
	boss_health -= note_damage
