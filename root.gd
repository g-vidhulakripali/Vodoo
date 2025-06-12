extends Node3D

@onready var detector = $DetectionRay
@onready var voodoo_mesh = $MeshInstance3D
@export var move_speed := 3.0
@export var rotate_speed := 60.0

var selected_target: Node3D = null
var has_selected := false
var original_voodoo_mesh: Mesh = null
var original_voodoo_scale: Vector3 = Vector3.ONE

func _ready():
	detector.enabled = true
	original_voodoo_mesh = voodoo_mesh.mesh
	original_voodoo_scale = voodoo_mesh.scale

func _process(delta):
	handle_movement(delta)

	if has_selected:
		handle_rotation(delta)
		sync_target_rotation()

	if Input.is_action_just_pressed("ui_accept"):
		handle_selection_toggle()

func handle_selection_toggle():
	detector.force_raycast_update()

	if has_selected:
		print("Deselected:", selected_target.name)
		selected_target = null
		voodoo_mesh.mesh = original_voodoo_mesh
		voodoo_mesh.scale = original_voodoo_scale
		has_selected = false
		global_rotation = Vector3.ZERO
	else:
		if detector.is_colliding():
			var hit = detector.get_collider()
			if hit.is_in_group("Pickable"):
				print("Selected Pickable:", hit.name)
				select_and_mimic(hit)
			else:
				print("Hit something but not Pickable")
		else:
			print("Raycast: No object detected")

func handle_movement(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		translate(direction * move_speed * delta)

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
		var new_mesh = target.get_node("MeshInstance3D").mesh
		voodoo_mesh.mesh = new_mesh
		voodoo_mesh.scale = target.get_node("MeshInstance3D").scale
		selected_target = target
		has_selected = true

func sync_target_rotation():
	if selected_target:
		selected_target.global_rotation = self.global_rotation
