extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if get_parent().id == get_tree().get_network_unique_id():
		self.current = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
