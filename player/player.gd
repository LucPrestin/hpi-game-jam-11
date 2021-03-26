extends KinematicBody2D
class_name Player

var id: int setget set_id
var texture_path: String setget _set_texture_path
const speed = 100
const texture_paths = [
	"02",
	"bear",
	"bee",
	"bat",
	"28"
	]

func _ready():
	add_to_group("players")
	
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTE)
	set_process(true)
	randomize()
	#position = Vector2(rand_range(0, get_viewport_rect().size.x), rand_range(0, get_viewport_rect().size.y))

	
	rset_config("texture_path", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	if is_network_master():
		rset("texture_path", "res://resources/monsters/%s.png" % texture_paths[randi() % texture_paths.size()])

func _physics_process(_delta):
	if not is_network_master():
		return
	
	var direction =  Vector2(0, 0)
	if Input.is_action_pressed("ui_up"):
		direction += Vector2(0, -1)
	if Input.is_action_pressed("ui_down"):
		direction += Vector2(0, 1)
	if Input.is_action_pressed("ui_left"):
		direction += Vector2(-1, 0)
	if Input.is_action_pressed("ui_right"):
		direction += Vector2(1, 0)
	
	if not direction.is_equal_approx(Vector2(0, 0)):
		$animator.set_directionv(direction)
		$animator.play_directional("move")
		move_and_slide(direction.normalized() * speed)
		rset("position", position)
	else:
		$animator.play_directional("idle")

func _set_texture_path(new_path: String):
	texture_path = new_path
	$Sprite.texture = load(self.texture_path)

func set_id(new_id: int):
	set_network_master(new_id)
	id = new_id

remotesync func kill():
	hide()
