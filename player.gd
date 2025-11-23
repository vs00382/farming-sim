extends CharacterBody2D

@export var speed: float = 120.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var last_direction := Vector2.DOWN

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	# Player is moving
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
		move_and_slide()

		# Save last direction
		last_direction = input_vector

		# --- Animation selection ---
		if abs(input_vector.x) > abs(input_vector.y):
			if anim.animation != "walk":
				anim.play("walk")
			anim.flip_h = input_vector.x < 0

		else:
			if input_vector.y < 0:
				if anim.animation != "walk_up":
					anim.play("walk_up")
			else:
				if anim.animation != "walk_down":
					anim.play("walk_down")

	# Player stopped → choose idle based on last direction
	else:
		velocity = Vector2.ZERO
		_play_idle_direction()

func _play_idle_direction() -> void:
	if abs(last_direction.x) > abs(last_direction.y):
		anim.flip_h = last_direction.x < 0
		if anim.animation != "idle_side":
			anim.play("idle_side")
	else:
		if last_direction.y < 0:
			if anim.animation != "idle_up":
				anim.play("idle_up")
		else:
			if anim.animation != "idle_down":
				anim.play("idle_down")
