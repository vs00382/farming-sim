# ObjectData.gd
extends Resource
class_name ObjectData

# --- Core Data ---
@export var id: String = "default_id"
@export var display_name: String = "Generic Object"
@export_enum("none", "crop", "item", "sign", "tree", "rock", "npc")
var object_type: String = "none"

# --- Sprite/TileSet Configuration ---
# Fallback for standalone images
@export var standalone_sprite: Texture2D

# Fields to reference a tile in a TileSet
@export var tileset: TileSet
@export var source_id: int = -1 					# The AtlasSource ID (e.g., 0)
@export var tile_atlas_coords: Vector2i = Vector2i(-1, -1) # The tile's grid coordinate (e.g., (4, 2))
# ------------------------------------

# --- Interaction/Gameplay Data ---
@export var interaction_text: String = ""

@export var item_drop: String = "" 
@export var item_drop_quantity: int = 1 # <-- NEW: Quantity of the item dropped (Crucial for Inventory)

@export var tool_required: String = ""
@export var max_health: int = 1

# --- Crop-specific fields (Kept for initial planting state or static crop models) ---
# We will manage the complex growth steps in the separate Crop.gd node.
@export var growth_stages: Array[Texture2D] = []
@export var growth_time: float = 0.0
