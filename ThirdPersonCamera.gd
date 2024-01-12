extends Node3D

class_name ThirdPersonCamera
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cam : Camera3D
var target : Node3D
@export var target_path : NodePath
var focused : bool = false
var info : bool = true
var ppos : Vector3
var ui : VBoxContainer
var posv : VectorInfo
var oriv : VectorInfo
var vv : VectorInfo
@export var dist_scale : float = 0.025
@export var rot_speed : float = 0.015

# Called when the node enters the scene tree for the first time.
func _ready():
	cam = get_node("Camera")
	ui = get_node("Camera/InfoContainer")
	posv = get_node("Camera/InfoContainer/Pos")
	oriv = get_node("Camera/InfoContainer/Ori")
	vv = get_node("Camera/InfoContainer/LinVel")
	target = get_node_or_null(target_path)
	set_focus(false)
	pass # Replace with function body.

func set_target(t : Node3D):
	target = t
	target_path = t.get_path()

func set_focus(focus : bool):
	if focus:
		cam.make_current()
		if not cam.is_current():
			print("Cannot make camera current!")
		set_process(true)
		set_process_input(true)
		ui.visible = true
		focused = true
	else:
		set_process(false)
		set_process_input(false)
		ui.visible = false
		focused = false

func copy_target_loc():
	set_position(target.global_position)

func copy_target_rot():
	transform.basis = target.global_transform.basis

func _input(event):
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_RIGHT:
			var mv = -event.relative * rot_speed
			rotate_object_local(Vector3(0, 1, 0), mv.x)
			rotate_object_local(Vector3(1, 0, 0), mv.y)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			var mv = cam.position.z * dist_scale
			cam.translate_object_local(Vector3(0, 0, -mv))
#			print("Wheel up: %f" % cam.translation.z)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
#			print("Wheel down")
			var mv = cam.position.z * dist_scale
			cam.translate_object_local(Vector3(0, 0, mv))
#			print("Wheel down: %f" % cam.translation.z)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		copy_target_loc()
		if info:
			var pos = target.position
			posv.value = pos
			var ori = target.rotation_degrees
			oriv.value = ori
			var pv = (ppos - pos) / delta
			vv.value = pv
			ppos = pos
