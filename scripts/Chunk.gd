extends MeshInstance

const CHUNKSIZE: int = 16

export (int) var chunk_x = 0
export (int) var chunk_y = 0
export (int) var chunk_z = 0
export (int) var worldseed = 0

# an array of directorys containing changes in this chunk.
# example: create air block at (0, 0, 0)
# { pos: {x: 0, y: 0, z: 0}, change: {
#						gen_mesh = false,
#						color = Color(1.0, 0.0, 0.0),
#						solid = false
#				}}
var changes = []

# a cube made out of 6 quads, a quad is made out of 2 triangles
const TRIANGLECUBE = [
	{
		normal = Vector3(0, 1, 0),
		int_normal = [0, 1, 0],
		vertecies = [
			Vector3(-1, 1, 1), 
			Vector3(-1, 1, -1),
			Vector3(1, 1, -1),
			Vector3(1, 1, -1),
			Vector3(1, 1, 1),
			Vector3(-1, 1, 1)]
	},
	{
		normal = Vector3(0, -1, 0),
		int_normal = [0, -1, 0],
		vertecies = [
			Vector3(-1, -1, 1),
			Vector3(1, -1, 1),
			Vector3(1, -1, -1),
			Vector3(1, -1, -1),
			Vector3(-1, -1, -1),
			Vector3(-1, -1, 1), 
			]
	},
	{
		normal = Vector3(1, 0, 0),
		int_normal = [1, 0, 0],		
		vertecies = [
			Vector3(1, -1, 1),
			Vector3(1, 1, 1),
			Vector3(1, 1, -1),
			Vector3(1, 1, -1),
			Vector3(1, -1, -1),
			Vector3(1, -1, 1), 
			]
	},
	{
		normal = Vector3(-1, 0, 0),
		int_normal = [-1, 0, 0],
		vertecies = [
			Vector3(-1, -1, 1),
			Vector3(-1, -1, -1),
			Vector3(-1, 1, -1),
			Vector3(-1, 1, -1),
			Vector3(-1, 1, 1),
			Vector3(-1, -1, 1), 
			]
	},
	{
		normal = Vector3(0, 0, -1),
		int_normal = [0, 0, 1],
		vertecies = [
			Vector3(-1, 1, -1),
			Vector3(-1, -1, -1),
			Vector3(1, -1, -1),
			Vector3(1, -1, -1),
			Vector3(1, 1, -1),
			Vector3(-1, 1, -1), 
			]
	},
	{
		normal = Vector3(0, 0, 1),
		int_normal = [0, 0, -1],
		vertecies = [
			Vector3(-1, 1, 1),
			Vector3(1, 1, 1),
			Vector3(1, -1, 1),
			Vector3(1, -1, 1),
			Vector3(-1, -1, 1),
			Vector3(-1, 1, 1), 
			]
	},
]



func is_inside_3Darray(position: Vector3, array_dimensions: Vector3)->bool:
	var not_negative: bool = position.abs() == position
	var inside_bounds_x: bool = position.x < array_dimensions.x
	var inside_bounds_y: bool = position.y < array_dimensions.y
	var inside_bounds_z: bool = position.z < array_dimensions.z
	return not_negative and inside_bounds_x and inside_bounds_y and inside_bounds_z


# cubeworld 3D array is an 3D array of cubes: a cube is a directory with the following components
#					var example_cube = {
#						gen_mesh = false,
#						color = Color(1.0, 0.0, 0.0),
#						solid = true
#				}
func cubeworld3D(cubeworld3Darray):
	var surfacetool = SurfaceTool.new()
	surfacetool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = cubeworld3Darray.size()
	var width = cubeworld3Darray[0].size()
	var depth = cubeworld3Darray[0][0].size()
	var array_3D_dimensions = Vector3(width, height, depth)
	for y in range(height):
		for x in range(width):
			for z in range(depth):
				var current_cube = cubeworld3Darray[y][x][z]
				if not current_cube.gen_mesh or not current_cube.solid:
					continue
				var current_cube_color = current_cube.color
				var array_cube_position = Vector3(x, y, z)
				var center_cube_geometry = Vector3(x*2, y*2, z*2)
				for quad in TRIANGLECUBE:
					var quad_normal: Vector3 = quad.normal
					var neighbor_index_2_check: Vector3 = array_cube_position + quad_normal
					var gen_quad_mesh = true
					if is_inside_3Darray(neighbor_index_2_check, array_3D_dimensions):
						var x2check: int = int(neighbor_index_2_check.x)
						var y2check: int = int(neighbor_index_2_check.y)
						var z2check: int = int(neighbor_index_2_check.z)
						gen_quad_mesh = not cubeworld3Darray[y2check][x2check][z2check].solid
					if gen_quad_mesh:
						for vertex in quad.vertecies:
							surfacetool.add_color(current_cube_color)
							surfacetool.add_normal(quad_normal)
							var chunk_coordinates = Vector3(chunk_x * CHUNKSIZE, chunk_y * CHUNKSIZE, chunk_z * CHUNKSIZE)							
							var vertex_coordinates = center_cube_geometry + vertex
							# make every cube 1x1x1 m big and allign them to the chunk grid.
							vertex_coordinates.x = (vertex_coordinates.x + 1)*0.5
							vertex_coordinates.y = (vertex_coordinates.y + 1)*0.5
							vertex_coordinates.z = (vertex_coordinates.z + 1)*0.5
							vertex_coordinates += chunk_coordinates
							# TODO: the outer shell of a chunk consists out of ... blocks with {gen_mesh = false}
							surfacetool.add_vertex(vertex_coordinates)
	self.mesh = surfacetool.commit()
	self.create_trimesh_collision()
	#print(self.mesh.get_faces())

#generate chunk using noise
func generate_chunk():
	var simplex_noise: OpenSimplexNoise = OpenSimplexNoise.new()
	simplex_noise.seed = self.worldseed
	var chunk = []
	for y in range(CHUNKSIZE):
		var xz_plane = []
		for x in range(CHUNKSIZE):
			var row = []
			for z in range(CHUNKSIZE):
				var eval_at_x = self.chunk_x * CHUNKSIZE + x
				var eval_at_z = self.chunk_z * CHUNKSIZE + z
				var noise_eval = (simplex_noise.get_noise_2d(eval_at_x, eval_at_z) + 1)/2 * (CHUNKSIZE -1)
				if y < noise_eval:
					row.append({
						gen_mesh = true,
						color = Color.red,
						solid = true
					})
				else:
					#air
					row.append(
						{
							gen_mesh = false,
							solid = false,
						}
					)
			xz_plane.append(row)
		chunk.append(xz_plane)
	return chunk

	
func apply_changed_mesh():
	var chunk = generate_chunk()
	for change in self.changes:
		var x = change.pos.x
		var y = change.pos.y
		var z = change.pos.z
		chunk[y][x][z] = change.change
	cubeworld3D(chunk)


func generate_chunk_mesh():
	var chunk = generate_chunk()
	#print(chunk.size(), chunk[16*16*16/2 ..])
	cubeworld3D(chunk)

#takes global coordinates
func destroy_block(x: int, y: int, z: int):
	#check if block is in self:
	var inside_x = self.chunk_x * CHUNKSIZE <= x and self.chunk_x * CHUNKSIZE + CHUNKSIZE > x
	var inside_y = self.chunk_y * CHUNKSIZE <= y and self.chunk_y * CHUNKSIZE + CHUNKSIZE > y
	var inside_z = self.chunk_z * CHUNKSIZE <= z and self.chunk_z * CHUNKSIZE + CHUNKSIZE > z
	# check if block is in chunk: ...	
	if not inside_x or not inside_y or not inside_z:
		print("cant place it here ....") 
		return
	var local_x: int = x % CHUNKSIZE
	var local_y: int = y % CHUNKSIZE
	var local_z: int = z % CHUNKSIZE
	# air block
	var change = {
			pos = {x = local_x, y = local_y, z = local_z},
			change = {solid = false, gen_mesh = false}
		}
	if !self.changes.has(change):
		self.changes.append(change)
	else:
		print("change already there")
	self.apply_changed_mesh()
	
func _ready():
	generate_chunk_mesh()
