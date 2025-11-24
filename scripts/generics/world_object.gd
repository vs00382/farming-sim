extends Area2D
class_name WorldObject

@export var data: ObjectData

var health: int

func _ready():
	# 1. Initialize Health
	health = data.max_health
	
	# 2. Set the Sprite Texture using the TileSet/Sprite data
	set_sprite_texture()


# --- Sprite Handling Function ---

func set_sprite_texture():
	var sprite_texture: Texture2D = null

	# Priority 1: Use a standalone sprite if defined
	if data.standalone_sprite:
		sprite_texture = data.standalone_sprite
	
	# Priority 2: Generate the texture from TileSet data
	elif data.tileset and data.source_id != -1 and data.tile_atlas_coords != Vector2i(-1, -1):
		sprite_texture = _create_atlas_texture_from_tile_data(data)
	
	# Apply the texture to the Sprite2D node
	if sprite_texture:
		# Assumes the Sprite2D child is named "Sprite2D"
		$Sprite2D.texture = sprite_texture 
	else:
		push_error("Could not set texture for WorldObject. ID: %s. Missing valid sprite or TileSet data." % data.id)


func _create_atlas_texture_from_tile_data(data: ObjectData) -> AtlasTexture:
	# Get the Atlas Source from the TileSet
	var source = data.tileset.get_source(data.source_id)
	if not source is TileSetAtlasSource:
		push_error("Source ID %d is not a TileSetAtlasSource." % data.source_id)
		return null

	# Get the texture and region data for the specific tile
	var tile_texture = source.get_texture()
	var tile_region = source.get_tile_texture_region(data.tile_atlas_coords)

	# Create the AtlasTexture which crops the texture to the tile's region
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = tile_texture
	atlas_texture.region = tile_region

	return atlas_texture

# --- Interaction Logic ---

func interact():
	match data.object_type:
		"item":
			pickup_item()
		"sign":
			show_text()
		"crop":
			harvest_crop()
		"tree", "rock":
			hit_obstacle()
		"npc":
			talk_to_npc()
		_:
			print("Generic interact with:", data.display_name)


func pickup_item():
	print("Picked up:", data.display_name)
	# Add logic here to remove the item from the world and add it to inventory


func show_text():
	# Use a UI manager to display data.interaction_text
	print(data.interaction_text)


func harvest_crop():
	print("Harvesting:", data.display_name)
	# Add logic to drop items and reset/remove the crop


func hit_obstacle():
	health -= 1
	print("Hit", data.display_name, "Health:", health)
	if health <= 0:
		destroy_object()


func talk_to_npc():
	# Trigger dialogue system
	print("Talking to:", data.display_name)

func destroy_object():
	print(data.display_name, " destroyed.")
	# Add item drop logic here (using data.item_drop)
	queue_free()
