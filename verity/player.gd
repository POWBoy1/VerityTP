extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Keeps track of which animation is currently active (defaults to "happy")
var current_anim: String = "happy"

func _ready() -> void:
	# Play "happy" immediately when the player spawns
	animated_sprite.play("happy")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Flip the sprite left or right when moving
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	move_and_slide()

# --- STANDBY HELPER ---
# Whenever you're ready to use "blank", "glammedup", "moggity", "sad", or "smiley",
# just call change_animation("animation_name") from anywhere in this script.
func change_animation(anim_name: String) -> void:
	if current_anim != anim_name:
		current_anim = anim_name
		animated_sprite.play(current_anim)
