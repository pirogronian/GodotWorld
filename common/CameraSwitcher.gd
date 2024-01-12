extends Node

class_name CameraSwitcher

var focused : Node3D
@export var cams : Array
@export var current_cam_index : int = 0
@export var switch_action : String = "F1"

func get_cam_num() -> int:
	return cams.size()

func get_cam(i : int) -> Node3D:
	if i < cams.size():
		return cams[i]
	else:
		return null

# Called when the node enters the scene tree for the first time.
func _ready():
#	print("CamSwitcher: Restoring focus...")
#	print("Cams: #", cams.size())
#	print("Restoring focus to cam #", current_cam_index)
#	focus_cam(current_cam_index)
	pass # Replace with function body.

func get_camnode(v) -> Node3D:
	if v is int:
		if v < 0 or v >= cams.size():
			print("Camera index out of range: ", v, ", ", cams.size())
			return null
		v = cams[v]
	if v is NodePath:
		return get_node(v)
	print("Argument is neither int nor NodePath!")
	return null

func focus_cam(v):
	var camnode = get_camnode(v)
	if camnode == null:
		return
	focused = camnode
	if camnode.has_method("set_focus"):
		print("Focus to 3-rd person camera...")
		camnode.set_focus(true)
	else:
		print("Focus to raw camera...")
		camnode.make_current()
		if not camnode.is_current():
			print("Cannot make this camera current!")

func unfocus_cam(v):
	var camnode = get_camnode(v)
	if camnode == null:
		return
	if camnode.has_method("set_focus"):
		camnode.set_focus(false)

func focus_next_cam():
	if cams.size() < 2:
		return
	unfocus_cam(current_cam_index)
	current_cam_index = current_cam_index + 1
	if current_cam_index == cams.size():
		current_cam_index = 0
	focus_cam(current_cam_index)

func restore_focus():
	focus_cam(current_cam_index)

func _input(event):
	if event.is_action_pressed(switch_action):
		focus_next_cam()

