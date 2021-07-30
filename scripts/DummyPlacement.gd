extends MeshInstance

onready var player_raycast: RayCast = $GlobalTransform/GodModePlayer/RayCast
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	if player_raycast.is_colliding():
		self.visible = true
		var collision_point: Vector3 = player_raycast.get_collision_point()
		var collision_normal: Vector3 = player_raycast.get_collision_normal()
		self.global_transform.origin = collision_point
