extends Object
class_name FlowerTextures

static func get_healthy_texture():
	var texture_id = randi() % 12 + 1
	return "res://resources/flora/flower_%s.png" % texture_id

static func get_burnt_texture():
	var texture_id = randi() % 5 + 1
	return "res://resources/flora/burnt_tree_%s.png" % texture_id
