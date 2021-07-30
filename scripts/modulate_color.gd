extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var mymaterial: SpatialMaterial = self.get_active_material(0)
#default: once per second
export (float) var period = 1
export (float) var min_alpha = 0.5
export (float) var max_alpha = 1.0

var cumulant: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var factor = 1.0/ period
	cumulant += delta
	cumulant *= factor
	# saw wave with period
	cumulant = cumulant - int(cumulant)
	var alpha: float =  (sin(2*PI*cumulant) + 1.0) * 0.5 * (max_alpha - min_alpha) + min_alpha
	self.mymaterial.albedo_color.a = alpha
