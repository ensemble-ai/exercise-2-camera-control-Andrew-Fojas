class_name LerpTargetFocus
extends CameraControllerBase

@export var lead_speed: float = 0.25
@export var catchup_delay_duration: float = 0.2
@export var catchup_speed: float = 5.0
@export var leash_distance: float = 15.0
var timer: float = 0.0

func _ready() -> void:
	super()
	draw_camera_logic = true
	position = target.position

func _process(delta: float) -> void:
	if !current:
		return

	if draw_camera_logic:
		draw_logic()

	# Leash the camera to the vessel on x-axis
	if position.x < target.position.x - leash_distance:
		position.x = target.position.x - leash_distance
	elif position.x > target.position.x + leash_distance:
		position.x = target.position.x + leash_distance

	# Leash camera to the vessel on z-axis
	if position.z < target.position.z - leash_distance:
		position.z = target.position.z - leash_distance
	elif position.z > target.position.z + leash_distance:
		position.z = target.position.z + leash_distance

	# Lead the camera in front of the vessel
	var desired_position = target.position
	if target.velocity.length() > 0:
		var direction = target.velocity.normalized()
		desired_position += direction * leash_distance
	

	# If the vessel is not moving, delay lerping the camera back to the target 
	if target.velocity.length() == 0:
		timer += delta
		if timer >= catchup_delay_duration:
			position = lerp(position, target.position, catchup_speed * delta)
	# If the vessel is moving, reset the timer and lerp the camera towards the desired position
	else:
		timer = 0.0
		position = lerp(position, desired_position, lead_speed * target.velocity.length() * delta)

	super(delta)

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# 5x5 cross
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(-2.5, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(2.5, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, -2.5))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, 2.5))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	# mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
