extends Area2D
class_name WorldObject

@export var data: ObjectData

var health: int

func _ready():
	health = data.max_health
	$Sprite2D.texture = data.sprite


func interact():
	match data.object_type:
		"item":
			pickup_item()
		"sign":
			show_text()
		"crop":
			harvest_crop()
		"tree", "rock":
			hit_obstacle()
		"npc":
			talk_to_npc()
		_:
			print("Generic interact with:", data.display_name)


func pickup_item():
	print("Picked up:", data.display_name)


func show_text():
	print(data.interaction_text)


func harvest_crop():
	print("Harvesting:", data.display_name)


func hit_obstacle():
	health -= 1
	print("Hit", data.display_name, "Health:", health)


func talk_to_npc():
	print("Talking to:", data.display_name)
