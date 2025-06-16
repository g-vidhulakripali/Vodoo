extends Node3D

@onready var detector = $DetectionRay
@onready var voodoo_mesh = $MeshInstance3D
@onready var spawn_point = $VoodooSpawnPoint

@export var move_speed := 1.0
@export var rotate_speed := 60.0

const MAX_DOLL_MOVE := 0.5  # how far the doll can move from center
const AMPLIFICATION := 3.0  # how much to multiply movement for the real object


var selected_target: Node3D = null
var has_selected := false
var original_voodoo_mesh: Mesh = null
var original_voodoo_scale: Vector3 = Vector3.ONE
var target_initial_position: Vector3
var voodoo_initial_position: Vector3

func _ready():
	detector.enabled = true
	original_voodoo_mesh = voodoo_mesh.mesh
	original_voodoo_scale = voodoo_mesh.scale
	voodoo_mesh.visible = true

func _process(delta):
	handle_movement(delta)

	if has_selected:
		handle_rotation(delta)
		sync_target_transform()
		apply_color()

	if Input.is_action_just_pressed("ui_accept"):
		handle_selection_toggle()

func handle_selection_toggle():
	detector.force_raycast_update()

	if has_selected:
		print("Deselected:", selected_target.name)
		selected_target = null
		voodoo_mesh.mesh = original_voodoo_mesh
		voodoo_mesh.scale = original_voodoo_scale
		voodoo_mesh.material_override = null  # Ensure no color carries over
		rotation = Vector3.ZERO  # Reset rotation on deselection
		has_selected = false
	else:
		if detector.is_colliding():
			var hit = detector.get_collider()
			if hit.is_in_group("Pickable"):
				select_and_mimic(hit)
			else:
				print("Hit something but not Pickable")
		else:
			print("Raycast: No object detected")

func handle_movement(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y += 1
	if Input.is_action_pressed("move_down"):
		direction.y -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		global_translate(direction * move_speed * delta)

func handle_rotation(delta):
	var yaw = 0.0
	var pitch = 0.0

	if Input.is_action_pressed("rotate_left"):
		yaw -= rotate_speed * delta
	if Input.is_action_pressed("rotate_right"):
		yaw += rotate_speed * delta
	if Input.is_action_pressed("rotate_up"):
		pitch -= rotate_speed * delta
	if Input.is_action_pressed("rotate_down"):
		pitch += rotate_speed * delta

	rotate_y(deg_to_rad(yaw))
	rotate_x(deg_to_rad(pitch))

func select_and_mimic(target: Node3D):
	if target.has_node("MeshInstance3D"):
		var mesh_instance = target.get_node("MeshInstance3D")

		voodoo_mesh.mesh = mesh_instance.mesh
		voodoo_mesh.scale = mesh_instance.scale * 0.5
		voodoo_mesh.visible = true

		# Move voodoo to a fixed point in front of the camera/player
		global_transform.origin = spawn_point.global_transform.origin
		rotation = Vector3.ZERO

		selected_target = target
		target_initial_position = target.global_transform.origin
		voodoo_initial_position = global_transform.origin  # fixed control center

		has_selected = true

func sync_target_transform():
	if selected_target:
		# Limit the doll's range
		var offset = global_transform.origin - voodoo_initial_position

		# Clamp manually since Vector3 doesn't have .clamped()
		if offset.length() > MAX_DOLL_MOVE:
			offset = offset.normalized() * MAX_DOLL_MOVE

		global_transform.origin = voodoo_initial_position + offset

		# Amplify movement for real object
		var amplified_offset = offset * AMPLIFICATION
		selected_target.global_transform.origin = target_initial_position + amplified_offset

		# Copy rotation as usual
		selected_target.rotation = rotation
		
func change_color(color: Color):
	# Apply to voodoo doll
	if voodoo_mesh.material_override == null:
		voodoo_mesh.material_override = StandardMaterial3D.new()
	voodoo_mesh.material_override.albedo_color = color

	# Apply to selected target's MeshInstance3D
	if selected_target and selected_target.has_node("MeshInstance3D"):
		var mesh_node = selected_target.get_node("MeshInstance3D")

		if mesh_node.material_override == null:
			mesh_node.material_override = StandardMaterial3D.new()

		mesh_node.material_override.albedo_color = color

func apply_color():
	if Input.is_action_just_pressed("color_red"):
		change_color(Color(1, 0, 0))  # Red
	if Input.is_action_just_pressed("color_green"):
		change_color(Color(0, 1, 0))  # Green
	if Input.is_action_just_pressed("color_blue"):
		change_color(Color(0, 0, 1))  # Blue
