extends Area2D
class_name AreaWorldObject

@export var data: ObjectData

var health: int
# Reference to the global manager (set in _ready)
var game_manager: Node

func _ready():
	# Attempt to get the global GameManager singleton
	# This assumes GameManager is set as an Autoload/Singleton in Project Settings
	game_manager = get_node("/root/GameManager")
	if not game_manager:
		push_error("AreaWorldObject: GameManager Singleton not found!")

	if data:
		health = data.max_health
		_set_sprite_texture()
		# Connect to body_entered only if the object has a purpose
		if data.object_type == "item" or data.object_type == "sign":
			body_entered.connect(_on_body_entered)
	else:
		push_error("AreaWorldObject is missing ObjectData!")

func _set_sprite_texture():
	var sprite_texture = _get_texture_from_data(data)
	if sprite_texture:
		# Assuming you have a Sprite2D child named 'Sprite2D'
		$Sprite2D.texture = sprite_texture 

func _get_texture_from_data(data: ObjectData) -> Texture2D:
	# Handles fetching the correct texture based on ObjectData settings
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
	# Check if the colliding body is the player
	if body.is_in_group("player"):
		if data.object_type == "item":
			pickup_item()
		elif data.object_type == "sign":
			show_text()

func pickup_item():
	if not game_manager:
		push_error("Cannot pick up item: GameManager not available.")
		# Proceed with cleanup anyway to prevent collision lock
		_cleanup_after_pickup(0.0) 
		return
	
	print("==================================================")
	print(">>> PICKUP DETECTED: ", data.display_name)
	
	var quantity_added = 0
	
	# --- CORE INVENTORY ADDITION ---
	if data.item_drop != "":
		print(">>> ATTEMPTING TO ADD ITEM TO INVENTORY:")
		print(">>> ITEM ID BEING USED: ", data.item_drop) # DEBUG CHECK
		print(">>> QUANTITY BEING USED: ", data.item_drop_quantity) # DEBUG CHECK
		
		# Add the item to the global inventory manager
		var added = game_manager.inventory_manager.add_item(
			data.item_drop, 
			data.item_drop_quantity
		)
		
		if added:
			quantity_added = data.item_drop_quantity
			print("Successfully added %d %s to inventory." % [quantity_added, data.display_name])
		else:
			print("FAILED to add item. Check if '%s' is loaded in Inventory.gd." % data.item_drop)
			
	print("==================================================")
			
	# --- CLEANUP (JUICE ADDITIONS) ---
	# Assuming $PickupSparkles and $PickupSound exist as children
	var longest_duration = 0.0
	if $PickupSound:
		$PickupSound.play()
		if $PickupSound.stream:
			longest_duration = max(longest_duration, $PickupSound.stream.get_length())

	if $PickupSparkles:
		$PickupSparkles.restart() 
		longest_duration = max(longest_duration, $PickupSparkles.lifetime)

	_cleanup_after_pickup(longest_duration + 0.1) # Pass duration to helper cleanup function

func _cleanup_after_pickup(wait_time: float):
	# 1. Disconnect body_entered to prevent accidental multiple pickups
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered) 
		
	# 2. Hide the sprite and collision immediately
	if $Sprite2D:
		$Sprite2D.visible = false
	if $CollisionShape2D:
		$CollisionShape2D.disabled = true
	
	# 3. Use a one-shot Timer to queue_free the node after sound and sparkles finish
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = wait_time 
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func show_text():
	print("Sign Text:", data.interaction_text)
