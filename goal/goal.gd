tool
extends Node2D

export(float) var goal_area_radius = 1.0 setget _set_goal_area_radius

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_radius():
	return ($WinArea/WinCollisionArea.shape as CircleShape2D).radius

func overlaps_body(body: Node):
	return $WinArea.overlaps_body(body)

func _on_win_body_entered(_body):
	if is_network_master():
		Globals.get_level().rpc("check_win_condition")

func _set_goal_area_radius(new_radius):
	goal_area_radius = new_radius
	($WinArea/WinCollisionArea.shape as CircleShape2D).radius = (goal_area_radius + 0.5) * Globals.PIXEL_PER_TILE
	$WinArea.update()

func _on_WinAreaShape_draw():
	$WinAreaShape.draw_circle(
		$WinArea/WinCollisionArea.get_position(), 
		(goal_area_radius + 0.5) * Globals.PIXEL_PER_TILE, 
		Color.forestgreen
	)
