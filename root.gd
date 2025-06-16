extends Node3D

@onready var detector = $DetectionRay
@onready var voodoo_mesh = $MeshInstance3D
@onready var spawn_point = $VoodooSpawnPoint

@export var move_speed := 1.0
@export var rotate_speed := 60.0

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

	if Input.is_action_just_pressed("ui_accept"):
		handle_selection_toggle()

func handle_selection_toggle():
	detector.force_raycast_update()

	if has_selected:
		print("Deselected:", selected_target.name)
		selected_target = null
		voodoo_mesh.mesh = original_voodoo_mesh
		voodoo_mesh.scale = original_voodoo_scale
		rotation = Vector3.ZERO  # ✅ Reset rotation on deselection
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
		voodoo_mesh.scale = mesh_instance.scale * 0.5  # ✅ Increased from 0.3 to 0.5
		voodoo_mesh.visible = true

		global_transform.origin = spawn_point.global_transform.origin
		rotation = Vector3.ZERO

		selected_target = target
		target_initial_position = target.global_transform.origin
		voodoo_initial_position = global_transform.origin

		has_selected = true

func sync_target_transform():
	if selected_target:
		var delta = global_transform.origin - voodoo_initial_position
		selected_target.global_transform.origin = target_initial_position + delta
		selected_target.rotation = rotation
