extends Node2D
class_name BaseWorldObject # <-- Use this class_name for type hinting

@export var data: ObjectData # Your Resource definition

var health: int

func _ready():
	# Since this is a base class, _ready() handles only the shared setup
	if data:
		health = data.max_health
		set_sprite_texture()
	else:
		push_error("WorldObject is missing ObjectData resource!")

func set_sprite_texture():
	var sprite_texture: Texture2D = null

	# Logic to prioritize standalone sprite or generate AtlasTexture
	if data.standalone_sprite:
		sprite_texture = data.standalone_sprite
	elif data.tileset and data.source_id != -1 and data.tile_atlas_coords != Vector2i(-1, -1):
		sprite_texture = _create_atlas_texture_from_tile_data(data)
	
	if sprite_texture:
		# Use get_node_or_null() just in case the Sprite2D isn't available
		$Sprite2D.texture = sprite_texture 
	else:
		push_error("Could not set texture for WorldObject: %s" % data.id)


func _create_atlas_texture_from_tile_data(data: ObjectData) -> AtlasTexture:
	# (Copy the sprite generation logic from your previous WorldObject.gd here)
	var source = data.tileset.get_source(data.source_id)
	if not source is TileSetAtlasSource: return null

	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = source.get_texture()
	atlas_texture.region = source.get_tile_texture_region(data.tile_atlas_coords)
	return atlas_texture

# Define generic interaction functions here for sub-classes to override
func interact():
	# This should be implemented by the child classes
	pass
