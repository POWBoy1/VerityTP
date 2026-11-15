extends Node2D

@onready var _audio = $AudioStreamPlayer2D # Change this if your node has a different name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_audio.play()
