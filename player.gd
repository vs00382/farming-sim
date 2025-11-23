extends CharacterBody2D

@export var speed: float = 120.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray: RayCast2D = $RayCast2D

const INTERACT_DISTANCE := 16

var last_direction := Vector2.DOWN

func _ready():
	ray.enabled = true
	ray.exclude_parent = true

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		try_interact()

func try_interact():
	if ray.is_colliding():
		var target = ray.get_collider()
		if target and target.has_method("interact"):
			target.interact()

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
		move_and_slide()

		last_direction = input_vector

		# Update raycast direction
		if abs(input_vector.x) > abs(input_vector.y):
			ray.target_position = Vector2(sign(input_vector.x) * INTERACT_DISTANCE, 0)
		else:
			ray.target_position = Vector2(0, sign(input_vector.y) * INTERACT_DISTANCE)

		# Animation selection
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
