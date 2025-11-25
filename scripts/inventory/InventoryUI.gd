# InventoryUI.gd
extends Control

# Preload the entry scene for instancing
const ITEM_ENTRY_SCENE = preload("res://Scenes/InventoryItemEntry.tscn") # Adjust path!

@onready var item_list_container = $Panel/ScrollContainer/ItemListContainer
var item_entry_nodes: Dictionary = {} # Keeps track of existing entries (Key: item_id, Value: InventoryItemEntry node)

func _ready():
	# Connect to the global signal whenever the inventory changes
	GameManager.inventory_manager.inventory_changed.connect(update_ui_entry)
	# Perform an initial full draw on load
	full_redraw()

# Called once to draw the entire current inventory state
func full_redraw():
	# Clear old entries
	for child in item_list_container.get_children():
		child.queue_free()
	item_entry_nodes.clear()
	
	# Draw current items
	var inventory = GameManager.inventory_manager.get_all_items()
	for item_id in inventory:
		var quantity = inventory[item_id]
		if quantity > 0:
			_create_or_update_entry(item_id, quantity)

# Called by the signal when any single item changes quantity
func update_ui_entry(item_id: String, quantity: int):
	_create_or_update_entry(item_id, quantity)
	
func _create_or_update_entry(item_id: String, quantity: int):
	# Get the resource definition to fetch the item name
	var item_data = GameManager.inventory_manager.get_item_data(item_id)
	if not item_data:
		# Should not happen if items are loaded, but good practice to check
		return

	if item_entry_nodes.has(item_id):
		# Update existing entry
		var entry = item_entry_nodes[item_id]
		if quantity > 0:
			entry.update_entry(item_id, item_data.item_name, quantity)
		else:
			# Remove entry if quantity is zero
			entry.queue_free()
			item_entry_nodes.erase(item_id)
			
	elif quantity > 0:
		# Create a new entry
		var new_entry = ITEM_ENTRY_SCENE.instantiate()
		item_list_container.add_child(new_entry)
		new_entry.update_entry(item_id, item_data.item_name, quantity)
		item_entry_nodes[item_id] = new_entry
