extends Resource
class_name ObjectData

@export var id: String
@export var display_name: String = "Object"
@export var sprite: Texture2D

@export_enum("none", "crop", "item", "sign", "tree", "rock", "npc") 
var object_type: String = "none"

@export var interaction_text: String = ""            # for signs/NPCs
@export var item_drop: String = ""                   # for items/crops/rocks
@export var tool_required: String = ""               # "axe", "hoe", "pickaxe"
@export var max_health: int = 1                      # for breakable things

# Crop-specific fields:
@export var growth_stages: Array[Texture2D] = []
@export var growth_time: float = 0.0
