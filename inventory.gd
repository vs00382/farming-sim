# Inventory.gd
extends Node
class_name Inventory

# Key: Item ID (String, e.g., "basic_seed"), Value: Quantity (int)
var inventory_slots: Dictionary = {} 
# Key: Item ID (String), Value: The ItemData Resource (holds sell value, etc.)
var item_definitions: Dictionary = {}

# Signal to notify the UI or other systems when the inventory changes
signal inventory_changed(item_id, new_quantity)



# --- Setup ---

func _ready():
	# Load all item definitions when the game starts
	# In a full game, you might loop through a folder of resources.
	# For now, manually ensure all critical items (seeds, crops, stone) are loaded.
	load_item_definitions()

func load_item_definitions():
	# Replace these paths with the actual locations of your ItemData resources
	var stone_resource = load("res://Resources/Items/Stone.tres")
	var basic_seed_resource = load("res://Resources/Items/BasicSeed.tres")
	var carrot_seed = load("res://resources/data/inventory/CarrotSeedItem.tres")
	
	# Example loading logic
	if stone_resource:
		item_definitions[stone_resource.item_id] = stone_resource
	if basic_seed_resource:
		item_definitions[basic_seed_resource.item_id] = basic_seed_resource
	if carrot_seed:
		item_definitions[carrot_seed.item_id] = carrot_seed
		
	print("Inventory: Loaded %d item definitions." % item_definitions.size())

# --- Core Logic ---

## Adds an item to the inventory. Returns true on success.
func add_item(item_id: String, quantity: int = 1) -> bool:
	if !item_definitions.has(item_id):
		push_error("Inventory: Attempted to add unknown item ID: " + item_id)
		return false

	if inventory_slots.has(item_id):
		inventory_slots[item_id] += quantity
	else:
		# Check against a max inventory slot count here if needed (e.g., 20 unique slots)
		inventory_slots[item_id] = quantity
		
	inventory_changed.emit(item_id, inventory_slots[item_id])
	return true

## Removes an item from the inventory. Returns true on success.
func remove_item(item_id: String, quantity: int = 1) -> bool:
	if !inventory_slots.has(item_id):
		return false # Item not in inventory

	if inventory_slots[item_id] >= quantity:
		inventory_slots[item_id] -= quantity
		
		var new_quantity = inventory_slots[item_id]
		
		if new_quantity <= 0:
			inventory_slots.erase(item_id) # Remove entry if stack is empty
			new_quantity = 0 # Set quantity to 0 for the signal
			
		inventory_changed.emit(item_id, new_quantity)
		return true
	else:
		print("Inventory: Not enough %s to remove." % item_id)
		return false

## Returns the current count of a specific item.
func get_item_count(item_id: String) -> int:
	return inventory_slots.get(item_id, 0)
	
## Looks up and returns the ItemData resource for properties like sell price.
func get_item_data(item_id: String) -> Resource:
	return item_definitions.get(item_id)
	
## For debugging or UI display
func get_all_items() -> Dictionary:
	return inventory_slots
