extends Object
class_name FlowerInformation

static func get_healthy_texture():
	var texture_id = randi() % 12 + 1
	return "res://resources/flora/flower_%s.png" % texture_id

static func get_burnt_texture():
	var texture_id = randi() % 12 + 1
	return "res://resources/flora/flower_burnt_%s.png" % texture_id

static func can_collide():
	return false
