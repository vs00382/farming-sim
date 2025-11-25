# InventoryItemEntry.gd
extends HBoxContainer

@onready var name_label = $NameLabel
@onready var quantity_label = $QuantityLabel

var item_id: String

# Function to initialize and update the entry
func update_entry(new_item_id: String, item_name: String, quantity: int):
	item_id = new_item_id
	name_label.text = item_name
	quantity_label.text = "x%d" % quantity
