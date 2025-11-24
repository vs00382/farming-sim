extends Area2D
class_name AreaWorldObject

@export var data: ObjectData

var health: int

func _ready():
	if data:
		health = data.max_health
		_set_sprite_texture()
		body_entered.connect(_on_body_entered)
	else:
		push_error("AreaWorldObject is missing ObjectData!")

func _set_sprite_texture():
	var sprite_texture = _get_texture_from_data(data)
	if sprite_texture:
		$Sprite2D.texture = sprite_texture 

func _get_texture_from_data(data: ObjectData) -> Texture2D:
	# (Your existing _get_texture_from_data function here)
	if data.standalone_sprite:
		return data.standalone_sprite
	
	if data.tileset and data.source_id != -1:
		var source = data.tileset.get_source(data.source_id)
		if source is TileSetAtlasSource:
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = source.get_texture()
			atlas_texture.region = source.get_tile_texture_region(data.tile_atlas_coords)
			return atlas_texture
	return null

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and data.object_type == "item":
		pickup_item()
	elif body.is_in_group("player") and data.object_type == "sign":
		show_text()

func pickup_item():
	print("Picked up:", data.display_name)
	
	# --- JUICE ADDITIONS ---
	# 1. Emit sparkles!
	$PickupSparkles.restart() 
	
	# 2. Play the sound (ensure this node is called "PickupSound")
	$PickupSound.play() 
	
	# 3. Disconnect body_entered to prevent accidental multiple pickups
	body_entered.disconnect(_on_body_entered) 
	
	# 4. Hide the sprite and collision immediately
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	
	# 5. Use a one-shot Timer to queue_free the node after sound and sparkles finish
	#    Add a small buffer to the longest duration (either sound or sparkle lifetime)
	var sound_duration = $PickupSound.stream.get_length() if $PickupSound.stream else 0.0
	var sparkle_duration = $PickupSparkles.lifetime
	var longest_duration = max(sound_duration, sparkle_duration)
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = longest_duration + 0.1 # A small buffer
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func show_text():
	print("Sign Text:", data.interaction_text)
