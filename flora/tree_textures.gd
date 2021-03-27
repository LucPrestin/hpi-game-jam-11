extends Object
class_name TreeTextures

static func get_healthy_texture():
	var texture_id = randi() % 10 + 1
	return "res://resources/flora/tree_%s.png" % texture_id

static func get_burnt_texture():
	var texture_id = randi() % 5 + 1
	return "res://resources/flora/tree_burnt_%s.png" % texture_id
