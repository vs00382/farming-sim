# InventoryItemData.gd
extends Resource
class_name InventoryItemData # This class name must be used when creating .tres files

# --- Core Identity ---
@export var item_id: String = "" # Unique ID (e.g., "basic_seed", "withered_crop"). MUST match ObjectData.item_drop field.
@export var item_name: String = "Unnamed Item"
@export var description: String = "A simple item."

# --- Economic and Stacking ---
@export var sell_value: float = 0.0 # CRITICAL: How much cash it provides toward the Debt Clock
@export var buy_value: float = 0.0  # Used when buying seeds/supplies from Barrett
@export var max_stack_size: int = 99

# --- Categorization (For specific game mechanics) ---
@export_enum("General", "Seed", "Crop", "Tool", "Heirloom", "Chemical")
var category: String = "General"

# --- Visuals ---
@export var texture: Texture2D # For the inventory slot icon
