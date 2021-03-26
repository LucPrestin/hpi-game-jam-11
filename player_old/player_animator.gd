extends AnimationPlayer

var direction = "right"

func set_directionv(new_direction: Vector2):
	match new_direction.normalized().round():
		Vector2(1, 0):
			self.direction = "right"
		Vector2(-1, 0):
			self.direction = "left"
		Vector2(0, -1):
			self.direction = "up"
		Vector2(0, 1):
			self.direction = "down"

func play_directional(animation: String):
	self.play(animation + '_' + direction)

func enable_falling_track_for(name: String, value: bool):
	var animation = self.get_animation(name)
	animation.track_set_enabled(animation.find_track(@"Sprite:scale"), value)
	animation.track_set_enabled(animation.find_track(@"Sprite:position"), value)
	animation.track_set_enabled(animation.find_track(@"Sprite:modulate"), value)

func set_falling_animation(value: bool):
	self.enable_falling_track_for('death_right', value)
	self.enable_falling_track_for('death_left', value)
	self.enable_falling_track_for('death_up', value)
	self.enable_falling_track_for('death_down', value)
