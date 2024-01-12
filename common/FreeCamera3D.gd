extends Camera3D

class_name FreeCamera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("forward"):
		translate(Vector3(1, 0, 0) * delta)
	if Input.is_action_pressed("backward"):
		translate(Vector3(-1, 0, 0) * delta)
	if Input.is_action_pressed("left"):
		print("left")
		rotate_object_local(Vector3(1, 0, 0), delta)
	if Input.is_action_pressed("right"):
		print("right")
		rotate_object_local(Vector3(-1, 0, 0), delta)
	pass
