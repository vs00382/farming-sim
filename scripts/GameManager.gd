# GameManager.gd
extends Node

# --- Core Systems ---
var inventory_manager: Node

@onready var time_manager = $TimeManager # (Optional: If we split time logic later)

# --- Debt Clock Variables (from Feature 1) ---
var current_cash: float = 0.0
var days_until_payment: int = 90
var quarterly_payment_amount: float = 500.0

# --- State Variables ---
var is_day_active: bool = true # Prevents player actions during night transitions
var current_day: int = 1
var current_season: String = "Spring" # Useful for Yield Engine logic

# --- Signals ---
signal day_passed()
signal payment_due()

func _ready():
	# Wait for the first frame cycle to ensure the scene tree is constructed.
	# This prevents the Autoload from crashing on scene initialization.
	await get_tree().process_frame
	
	# Now try to find the Inventory node using its correct path
	inventory_manager = get_node_or_null("/root/World/GameManagerSetup/Inventory") 
	
	if inventory_manager:
		print("GameManager successfully found the Inventory node.")
		# Optional: You can also call inventory_manager.load_item_definitions() here
	else:
		push_error("CRITICAL ERROR: Inventory node not found at path /root/World/GameManagerSetup/Inventory")
		
# Called when the player chooses to sleep or ends the day
func pass_day():
	if !is_day_active:
		return # Prevents double-ticking
		
	is_day_active = false
	
	current_day += 1
	
	# 1. Update Debt Clock
	days_until_payment -= 1
	
	# 2. Inform the world (Tells crops to grow, weather to update)
	day_passed.emit()
	
	# 3. Check for Payment
	if days_until_payment <= 0:
		payment_due.emit()
		# The function that handles foreclosure/renewal will be called here
		
	# 4. Handle Season Change (Simple 90-day cycle for now)
	if current_day % 90 == 0:
		# Logic to change season (e.g., Spring -> Summer -> Fall -> Winter)
		pass
		
	# Introduce a brief delay (fade to black) then set is_day_active = true
	await get_tree().create_timer(1.0).timeout
	is_day_active = true
	print("--- Day %d starts. Days until payment: %d ---" % [current_day, days_until_payment])

# --- Financial Logic (from Inventory integration) ---

func sell_item(item_id: String, quantity: int) -> float:
	# Uses the Inventory Manager to remove items and updates cash
	var definition = inventory_manager.get_item_data(item_id)
	
	if definition == null:
		push_error("Cannot sell unknown item.")
		return 0.0
		
	if inventory_manager.remove_item(item_id, quantity):
		var revenue = definition.sell_value * quantity
		current_cash += revenue
		print("Sale complete. Current Cash: $%.2f" % current_cash)
		return revenue
	else:
		return 0.0
