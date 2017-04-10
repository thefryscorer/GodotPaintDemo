extends Spatial

var mesh
var meshtool

var paint = preload("res://paint.png")
var brush = preload("res://brush.png")

func _ready():
	mesh = get_node("mesh").get_mesh()
	meshtool = MeshDataTool.new()
	meshtool.create_from_surface(mesh, 0)

func equals_with_epsilon(v1, v2, epsilon):
	if (v1.distance_to(v2) < epsilon):
		return true
	return false

func get_face(point, normal, epsilon = 0.2):
	for idx in range(meshtool.get_face_count()):
		if !equals_with_epsilon(meshtool.get_face_normal(idx), normal, epsilon):
			continue
		# Normal is the same-ish, so we need to check if the point is on this face
		var v1 = meshtool.get_vertex(meshtool.get_face_vertex(idx, 0))
		var v2 = meshtool.get_vertex(meshtool.get_face_vertex(idx, 1))
		var v3 = meshtool.get_vertex(meshtool.get_face_vertex(idx, 2))
		if is_point_in_triangle(point, v1, v2, v3):
			return idx
	return null

func barycentric(P, A, B, C):
	# Returns barycentric co-ordinates of point P in triangle ABC
	var mat1 = Matrix3(A, B, C)
	var det = mat1.determinant()
	var mat2 = Matrix3(P, B, C)
	var factor_alpha = mat2.determinant()
	var mat3 = Matrix3(P, C, A)
	var factor_beta = mat3.determinant()
	var alpha = factor_alpha / det;
	var beta = factor_beta / det;
	var gamma = 1.0 - alpha - beta;
	return Vector3(alpha, beta, gamma)

func is_point_in_triangle(point, v1, v2, v3):
	var bc = barycentric(point, v1, v2, v3)
	if bc.x < 0 or bc.x > 1:
		return false
	if bc.y < 0 or bc.y > 1:
		return false
	if bc.z < 0 or bc.z > 1:
		return false
	return true

func get_uv_coords(point, normal):
	# Gets the uv coordinates on the mesh given a point on the mesh and normal
	# these values can be obtained from a raycast
	var face = get_face(point, normal)
	if face == null:
		return null
	var v1 = meshtool.get_vertex(meshtool.get_face_vertex(face, 0))
	var v2 = meshtool.get_vertex(meshtool.get_face_vertex(face, 1))
	var v3 = meshtool.get_vertex(meshtool.get_face_vertex(face, 2))
	var bc = barycentric(point, v1, v2, v3)
	var uv1 = meshtool.get_vertex_uv(meshtool.get_face_vertex(face, 0))
	var uv2 = meshtool.get_vertex_uv(meshtool.get_face_vertex(face, 1))
	var uv3 = meshtool.get_vertex_uv(meshtool.get_face_vertex(face, 2))
	return (uv1 * bc.x) + (uv2 * bc.y) + (uv3 * bc.z)
	
func paint_uv(point, normal, color):
	# Brush transfers onto the mesh's texture at the point and normal obtained from a raycast
	var uv = get_uv_coords(point, normal)
	if uv == null:
		return
	var rgb = mesh.surface_get_material(0).get_texture(FixedMaterial.PARAM_DIFFUSE)
	uv *= rgb.get_size()
	var data = rgb.get_data()
	#data.put_pixel(uv.x, uv.y, color)
	data.brush_transfer(paint.get_data(), brush.get_data(), Vector2(uv.x - brush.get_width()/2, uv.y - brush.get_height()/2))
	rgb.set_data(data)
	mesh.surface_get_material(0).set_texture(FixedMaterial.PARAM_DIFFUSE, rgb)