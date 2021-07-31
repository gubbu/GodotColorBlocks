extends RayCast


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var dummy_placement = $"../../../../DummyPlacement"
onready var debug_label: Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	if self.is_colliding():
		var collider = self.get_collider()
		var collision_point: Vector3 = self.get_collision_point()
		collision_point.x = int(collision_point.x)
		collision_point.z = int(collision_point.z)
		collision_point.y = int(collision_point.y)
		var normal: Vector3 = self.get_collision_normal()
		#print(collider, collision_point, normal)
		
		var selected_block = collision_point
		if normal.x > 0.0 or normal.y > 0.0 or normal.z > 0.0:
			selected_block -= normal
		
		dummy_placement.global_transform.origin = selected_block
		dummy_placement.visible = true
		
		if Input.is_action_just_pressed("Leftclick"):
			if collider is Node:
				var collider_parent = collider.get_parent()
				if collider_parent is Node:
					if collider_parent.is_in_group("terrain"):
						print("terrain found")
						var selected_block_x = int(selected_block.x)
						var selected_block_y = int(selected_block.y)
						var selected_block_z = int(selected_block.z)
						collider_parent.destroy_block(selected_block_x, selected_block_y, selected_block_z)

		
		debug_label.text = "selected block:" + str(selected_block) + "selected normal:" + str(normal)
	else:
		dummy_placement.visible = false
