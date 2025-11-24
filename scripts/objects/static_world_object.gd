extends StaticBody2D
class_name StaticWorldObject

@export var data: ObjectData

var health: int

func _ready():
	if data:
		health = data.max_health
		_set_sprite_texture()
		# No need for body_entered signals here, as it's for blocking
	else:
		push_error("StaticWorldObject is missing ObjectData!")

func _set_sprite_texture():
	# Call the same internal texture logic as the AreaWorldObject
	var sprite_texture = _get_texture_from_data(data)
	if sprite_texture:
		$Sprite2D.texture = sprite_texture 

func _get_texture_from_data(data: ObjectData) -> Texture2D:
	# IMPORTANT: Copy the full, working AtlasTexture generation function here
	# Since StaticBody2D doesn't inherit AreaWorldObject's methods, 
	# the function must be duplicated in this script or placed in an Autoload/Utility script.
	
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

# --- Hit/Interaction Logic (Triggered by player input or tool use) ---

# This function would be called externally by your Player/Tool script when they hit the object
func hit_obstacle():
	health -= 1
	print("Hit %s. Health: %d" % [data.display_name, health])
	if health <= 0:
		destroy_object()

func destroy_object():
	print(data.display_name, " destroyed and dropped %s." % data.item_drop)
	queue_free()
