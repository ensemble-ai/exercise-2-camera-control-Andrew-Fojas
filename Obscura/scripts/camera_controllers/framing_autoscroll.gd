class_name FramingAutoscroll
extends CameraControllerBase

@export var top_left: Vector2 = Vector2(-12, 3)
@export var bottom_right: Vector2 = Vector2(0, -7)
@export var autoscroll_speed: Vector3 = Vector3(5.0, 0.0, 5.0)

func _ready() -> void:
	super()
	draw_camera_logic = true
	position.x = target.position.x + 25
	position.y = target.position.y
	position.z = target.position.z + 25

func _process(delta: float) -> void:
	if !current:
		return
	if draw_camera_logic:
		draw_logic()

	# Update the camera position with autoscroll on x and z axes
	position.x += autoscroll_speed.x * delta
	position.z += autoscroll_speed.z * delta
	
	# Bound Vessel movement to the frame box
	if target.position.x < position.x + top_left.x:
		target.position.x = position.x + top_left.x
	if target.position.x > position.x + bottom_right.x:
		target.position.x = position.x + bottom_right.x
		
	if target.position.z < position.z + bottom_right.y:
		target.position.z = position.z + bottom_right.y
	if target.position.z > position.z + top_left.y:
		target.position.z = position.z + top_left.y

	super(delta)

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)

	# Draw the frame border based on top_left and bottom_right
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, top_left.y))

	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, bottom_right.y))

	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, bottom_right.y))

	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, top_left.y))

	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK

	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)

	# mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
