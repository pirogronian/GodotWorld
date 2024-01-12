extends Camera3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var translation_speed = 1
@export var rotation_speed = 1
@export var msg_timeout = 0
@export var has_input : bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setMsg(txt : String):
	msg_timeout = 1
	var msg = get_node("Msg")
	msg.set_text(txt)
	msg.visible = true

func processInput(delta):
	if Input.is_action_pressed("translation_speed_up"):
		translation_speed = translation_speed + delta
		setMsg("Transl speed: %f" % translation_speed)
#		print("Translation speed: ", translation_speed)
	if Input.is_action_pressed("translation_speed_down"):
		translation_speed = translation_speed - delta
		setMsg("Transl speed: %f" % translation_speed)
#		print("Translation speed: ", translation_speed)
	var tr_delta = delta * translation_speed
	var rot_delta = delta * rotation_speed
	if Input.is_action_pressed("yaw_left"):
		rotate_object_local(Vector3(0, 1, 0), rot_delta)
	if Input.is_action_pressed("yaw_right"):
		rotate_object_local(Vector3(0, 1, 0), -rot_delta)
	if Input.is_action_pressed("pitch_down"):
		rotate_object_local(Vector3(1, 0, 0), -rot_delta)
	if Input.is_action_pressed("pitch_up"):
		rotate_object_local(Vector3(1, 0, 0), rot_delta)
	if Input.is_action_pressed("roll_aclock"):
		rotate_object_local(Vector3(0, 0, 1), rot_delta)
	if Input.is_action_pressed("roll_clock"):
		rotate_object_local(Vector3(0, 0, 1), -rot_delta)
	if Input.is_action_pressed("ui_page_up"):
		translate_object_local(Vector3(0, 0, -tr_delta))
	if Input.is_action_pressed("ui_page_down"):
		translate_object_local(Vector3(0, 0, tr_delta))
	if Input.is_action_pressed("ui_up"):
		translate_object_local(Vector3(0, tr_delta, 0))
	if Input.is_action_pressed("ui_down"):
		translate_object_local(Vector3(0, -tr_delta, 0))
	if Input.is_action_pressed("ui_left"):
		translate_object_local(Vector3(-tr_delta, 0, 0))
	if Input.is_action_pressed("ui_right"):
		translate_object_local(Vector3(tr_delta, 0, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if msg_timeout < 0:
		msg_timeout = 0
		get_node("Msg").visible = false
	else:
		msg_timeout = msg_timeout - delta
		
	if has_input:
		processInput(delta)

#func _input(event):
#	if event.is_action("ui_left"):
#		rotate_y()
