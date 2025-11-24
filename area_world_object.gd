extends Area2D
class_name AreaWorldObject

@export var data: ObjectData

var health: int

func _ready():
	if data:
		health = data.max_health
		_set_sprite_texture()
		body_entered.connect(_on_body_entered) # Connect to detect player entry
	else:
		push_error("AreaWorldObject is missing ObjectData!")

func _set_sprite_texture():
	# Use the sprite generation logic you perfected
	var sprite_texture = _get_texture_from_data(data)
	if sprite_texture:
		$Sprite2D.texture = sprite_texture 

func _get_texture_from_data(data: ObjectData) -> Texture2D:
	# Your AtlasTexture generation logic goes here (copy the function from WorldObject.gd)
	if data.standalone_sprite:
		return data.standalone_sprite
	
	if data.tileset and data.source_id != -1:
		# Simplified: assumes successful generation using coordinates
		var source = data.tileset.get_source(data.source_id)
		if source is TileSetAtlasSource:
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = source.get_texture()
			atlas_texture.region = source.get_tile_texture_region(data.tile_atlas_coords)
			return atlas_texture
	return null

# --- Interaction Logic ---
func _on_body_entered(body: Node2D):
	# Example: Check for player and trigger interact()
	if body.is_in_group("player"):
		match data.object_type:
			"item":
				pickup_item()
			"sign":
				show_text()
			# ... other Area2D interactions
			_:
				pass

func pickup_item():
	print("Picked up:", data.display_name)
	
	# 1. Play the sound
	$PickupSound.play() 
	
	# 2. Prevent the object from being removed immediately
	#    We need to wait for the sound to finish playing before freeing the node.
	
	# 3. Disconnect body_entered to prevent accidental multiple pickups
	body_entered.disconnect(_on_body_entered) 
	
	# 4. Hide the sprite and collision to make it disappear instantly
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	
	# 5. Connect the signal that tells us when the audio finishes
	$PickupSound.finished.connect(_on_pickup_sound_finished)

# New function: called automatically when the sound finishes playing
func _on_pickup_sound_finished():
	# Now it's safe to remove the object
	queue_free()

func show_text():
	print("Sign Text:", data.interaction_text)
