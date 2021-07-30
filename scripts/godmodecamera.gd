extends Spatial

export var speed = 20
export var mouse_sensitivity = 0.003

onready var camera = $Camera

var exit_mode = false
#the object on which this script shall be aplied shall be a spatial with a camera as its child
# the camera and the spatial should have the same translation to avoid confusion. (?)
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		#if abs(event.relative.x) > abs(event.relative.y):
		self.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		if abs(camera.rotation.x) > PI/2:
			camera.rotate_x(event.relative.y * mouse_sensitivity)		

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		exit_mode = !exit_mode
		if exit_mode:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_key_pressed(KEY_W):
		#print(self.rotation.y)
		self.translation += Vector3(-sin(self.rotation.y), sin(camera.rotation.x), -cos(self.rotation.y)*cos(camera.rotation.x))*delta*speed
		#print("1 = |velocity|=", Vector3(-sin(self.rotation.y), sin(camera.rotation.x), -cos(self.rotation.y)*cos(camera.rotation.x)).length())
	elif Input.is_key_pressed(KEY_S):
		self.translation -= Vector3(-sin(self.rotation.y), sin(camera.rotation.x), -cos(self.rotation.y)*cos(camera.rotation.x))*delta*speed
	if Input.is_key_pressed(KEY_D):
		var rotation_right =  self.rotation.y+PI/2
		self.translation -= Vector3(-sin(rotation_right), 0, -cos(rotation_right))*delta*speed
	elif Input.is_key_pressed(KEY_A):
		var rotation_left =  self.rotation.y-PI/2
		self.translation -= Vector3(-sin(rotation_left), 0, -cos(rotation_left))*delta*speed	
