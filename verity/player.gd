extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

## Tunable movement values are exported so the game feel can be adjusted per scene.
@export var move_speed: float = SPEED
@export var ground_acceleration: float = 1800.0
@export var ground_friction: float = 2200.0
@export var air_acceleration: float = 1000.0
@export var jump_velocity: float = JUMP_VELOCITY
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.12
@export var jump_cut_multiplier: float = 0.45

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Keeps track of which animation is currently active (defaults to "happy")
var current_anim: String = "happy"
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _was_on_floor: bool = false
var _base_sprite_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	_base_sprite_scale = animated_sprite.scale
	_was_on_floor = is_on_floor()
	# Play "happy" immediately when the player spawns
	animated_sprite.play(current_anim)


func _physics_process(delta: float) -> void:
	var grounded_before_move: bool = is_on_floor()
	_coyote_timer = coyote_time if grounded_before_move else maxf(_coyote_timer - delta, 0.0)
	_jump_buffer_timer = jump_buffer_time if Input.is_action_just_pressed("jump") else maxf(_jump_buffer_timer - delta, 0.0)

	if not grounded_before_move:
		velocity += get_gravity() * delta

	var direction: float = Input.get_axis("left", "right")
	var acceleration: float = ground_acceleration if grounded_before_move else air_acceleration
	if not is_zero_approx(direction):
		velocity.x = move_toward(velocity.x, direction * move_speed, acceleration * delta)
	else:
		var braking: float = ground_friction if grounded_before_move else air_acceleration * 0.35
		velocity.x = move_toward(velocity.x, 0.0, braking * delta)

	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_play_squash(Vector2(0.82, 1.18), 0.08)

	# Releasing jump early cuts upward speed, giving the player control over jump height.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

	move_and_slide()
	_update_visuals(direction)

	var grounded_after_move: bool = is_on_floor()
	if grounded_after_move and not _was_on_floor:
		_play_squash(Vector2(1.2, 0.82), 0.10)
	_was_on_floor = grounded_after_move


# --- STANDBY HELPER ---
# Whenever you're ready to use "blank", "glammedup", "moggity", "sad", or "smiley",
# just call change_animation("animation_name") from anywhere in this script.
func change_animation(anim_name: String) -> void:
	if current_anim != anim_name:
		current_anim = anim_name
		animated_sprite.play(current_anim)


func _update_visuals(direction: float) -> void:
	if not is_zero_approx(direction):
		animated_sprite.flip_h = direction < 0.0

	if not is_on_floor():
		return

	if absf(velocity.x) > 8.0:
		if animated_sprite.sprite_frames.has_animation(current_anim):
			animated_sprite.play(current_anim)
	else:
		animated_sprite.stop()
		animated_sprite.frame = 0


func _play_squash(target_scale: Vector2, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_sprite, "scale", _base_sprite_scale * target_scale, duration)
	tween.tween_property(animated_sprite, "scale", _base_sprite_scale, duration * 1.5)
