class_name KillBrick
extends Area2D

## A reusable hazard block. Anything that touches it and knows how to die
## (i.e. exposes a `kill()` method, like the player) gets respawned.

## Optional: how long this hazard stays inactive after killing the player,
## so a respawn overlapping the hazard can't loop instantly.
@export var cooldown: float = 0.4

var _cooling_down: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _cooling_down:
		return
	if body.has_method("kill"):
		body.kill()
		_cooling_down = true
		await get_tree().create_timer(cooldown).timeout
		_cooling_down = false