extends RigidBody3D

@export var motion_resource = 1000
@export var lin_thrust : float = 1
@export var rot_thrust : float = 0.001
var mres_label : Label
var linear_thrust : Vector3
var rotation_thrust : Vector3
const RotationActionsVector = {
	"yaw_left" : Vector3(0, -1, 0),
	"yaw_right" : Vector3(0, 1, 0),
	"pitch_up" : Vector3(1, 0, 0),
	"pitch_down" : Vector3(-1, 0, 0),
	"roll_aclock" : Vector3(0, 0, -1),
	"roll_clock" : Vector3(0, 0, 1)
}

const LinearActionsVector = {
	"forward" : Vector3(0, 0, -1),
	"backward" : Vector3(0, 0, 1),
	"up" : Vector3(0, 1, 0),
	"down" : Vector3(0, -1, 0),
	"left" : Vector3(-1, 0, 0),
	"right" : Vector3(1, 0, 0),
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func forceCost(f : Vector3, dt : float):
	return f.length() * dt / 2

func torqueCost(f : Vector3, dt : float):
	return f.length() * dt / 4

func linIToRes(i : float):
	return i / 2

func rotIToRes(i : float):
	return i / 4

func resToLinI(r : float):
	return r * 2

func resToRotI(r : float):
	return r * 4

func actLinImpulse(i : Vector3):
	var cost = linIToRes(i.length())
	if cost > motion_resource:
		cost = motion_resource
		motion_resource = 0
		i = resToLinI(cost)
	else:
		motion_resource = motion_resource - cost
	apply_central_impulse(i)
	updateMotionResourceInfo()

func actRotImpulse(i : Vector3):
	var cost = rotIToRes(i.length())
	if cost > motion_resource:
		cost = motion_resource
		motion_resource = 0
		i = resToRotI(cost)
	else:
		motion_resource = motion_resource - cost
	apply_torque_impulse(i)
	updateMotionResourceInfo()
	

func checkInputEvent(event : InputEvent):
	if event is InputEventAction:
		if RotationActionsVector.has(event.name):
			var thrust = RotationActionsVector.get(event.name) * lin_thrust
			if event.pressed && Input:
				linear_thrust = thrust
			else:
				pass
#				lin_thrust
	pass

func processInput(delta):
	var lin_imp : Vector3
	var rot_imp : Vector3
	
	if Input.is_action_pressed("yaw_left"):
		rot_imp = Vector3(0, -1, 0)
	if Input.is_action_pressed("yaw_right"):
		rot_imp =  Vector3(0, 1, 0)
	if Input.is_action_pressed("pitch_down"):
		rot_imp = Vector3(-1, 0, 0)
	if Input.is_action_pressed("pitch_up"):
		rot_imp = Vector3(1, 0, 0)
	if Input.is_action_pressed("roll_aclock"):
		rot_imp = Vector3(0, 0, -1)
	if Input.is_action_pressed("roll_clock"):
		rot_imp = Vector3(0, 0, 1)
	if Input.is_action_pressed("forward"):
		lin_imp = Vector3(0, 0, -1)
	if Input.is_action_pressed("backward"):
		lin_imp = Vector3(0, 0, 1)
	if Input.is_action_pressed("up"):
		lin_imp = Vector3(0, 1, 0)
	if Input.is_action_pressed("down"):
		lin_imp = Vector3(0, -1, 0)
	if Input.is_action_pressed("left"):
		lin_imp = Vector3(-1, 0, 0)
	if Input.is_action_pressed("right"):
		lin_imp = Vector3(1, 0, 0)
	rot_imp = rot_imp * delta * rot_thrust
	lin_imp = lin_imp * delta * lin_thrust
	if rot_imp.length() > 0:
		actRotImpulse(rot_imp)
	if lin_imp.length() > 0:
		actLinImpulse(lin_imp)

func updateMotionResourceInfo():
	mres_label.set_text("Motion resource: %d" % motion_resource)

# Called when the node enters the scene tree for the first time.
func _ready():
	mres_label = get_node("MotionResourceLabel")
	updateMotionResourceInfo()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	processInput(delta)
#	pass

func _input(event):
	if event.is_action_pressed("debug_ui"):
		print("Toggle debug dialog")
		var ddialog = get_node("TransformInfoWindow")
		if ddialog.visible:
			print("Hide debug dialog")
			ddialog = false
		else:
			print("Show debug dialog")
			ddialog.popup()
	pass
