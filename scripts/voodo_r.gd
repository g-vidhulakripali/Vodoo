extends XRController3D

@onready var ray_cast = $DetectionRay
@onready var ray_visual = $RayVisual
@export var voodoo_left_mesh:MeshInstance3D = null
@export var floating_prompt:Label3D = null
@export var pickable:Node3D = null
@export var holder:Node3D = null
@export var override_material : StandardMaterial3D = null

var cloned_instance:Node3D =  null
var voodo_enabled:Array[Node3D]
var mesh_instance:MeshInstance3D
var collider
var isClicked:bool
var default_mesh:MeshInstance3D = null
var is_dragging := false

class Voodoo:
	var origin : Node3D
	var voodoo : Node3D

var voodoo_list : Array[Voodoo] = []

var last_controller_basis := Basis() 
var is_rotating := false

func _ready() -> void:
	for c in pickable.get_children():
		if c.is_in_group("Pickable"):
			voodo_enabled.append(c)
	default_mesh = voodoo_left_mesh
	if(voodoo_left_mesh): 
		print("it is there")
	else:
		print("it is not there !!! hahahah")
	
	if !voodo_enabled.is_empty():
		voodo_enabled.clear()

func _process(delta: float) -> void:
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y += 1
	if Input.is_action_pressed("move_down"):
		direction.y -= 1
	global_translate(direction*delta)

	# Optional: Mouse to rotate
	var mouse_delta = Input.get_last_mouse_velocity()
	rotate_y(-mouse_delta.x * delta * 0.01)
	if not is_instance_valid(ray_cast) or not is_instance_valid(ray_visual):
		return
	
	if ray_cast.is_colliding():
		floating_prompt.text = "Object selected - \n Press trigger to clone"
		collider = ray_cast.get_collider()
	else:
		floating_prompt.text = "Select"
		collider = null
	
				
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("simulate_trigger"):
		_on_button_pressed("trigger_click")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed  # True when pressed, False when released

	elif event is InputEventMouseMotion and is_dragging:
		_on_button_released("grip_click")


func _on_button_pressed(name: String) -> void:
	var isClicked = false
	var highlight_mat = func (m3d : MeshInstance3D):
		m3d.material_override = override_material
		
	#var staticPosition = func (m3d: MeshInstance3D):
		#m3d.global_position =voodoo_left_mesh.global_position
	
	var scaling = func (m3d: MeshInstance3D):
		m3d.scale = Vector3(0.1,0.1,0.1)

	var scalingCollion = func (m3d: CollisionShape3D):
		m3d.scale = Vector3(0.1,0.1,0.1)
		
	if name == "trigger_click":
		if !voodo_enabled.is_empty():
			print("thid should be working")
			holder.remove_child(voodo_enabled[0])
			voodo_enabled.clear()
			voodoo_list.clear()
			
		if collider and  collider.is_in_group("Pickable"):
			
			print(collider.name + " collider vodo ", voodo_enabled)
			var clone = collider.duplicate(true)
			#var clone := collider.duplicate(true) as Node3D
			
			if voodo_enabled.is_empty():
				var vc=Voodoo.new()
				vc.origin = collider
				voodo_enabled.append(clone)
				holder.add_child(voodo_enabled[0])
				
				voodo_enabled[0].freeze = true
				
				vc.voodoo = clone
				
				voodoo_list.append(vc)
				
				apply_to_subtree(voodo_enabled[0],'MeshInstance3D',highlight_mat)
				voodo_enabled[0].global_position = voodoo_left_mesh.global_position
				#apply_to_subtree(voodo_enabled[0],'MeshInstance3D',staticPosition)
				print(voodoo_left_mesh.global_position," Voodo-",voodo_enabled[0].position , " Global-", voodo_enabled[0].global_position)
				#apply_to_subtree(voodo_enabled[0],'MeshInstance3D',scaling)
				#apply_to_subtree(voodo_enabled[0],'CollisionShape3D',scalingCollion)
				#voodo_enabled[0].global_scale(Vector3(0.5,0.5,0.5))				
	if !isClicked:
		pass
		#voodoo_left_mesh.mesh = default_mesh.mesh
	
	if name == "grip_click":
		is_rotating = true
		last_controller_basis = global_transform.basis
		
 # Replace with function body.
static func apply_to_subtree(node:Node,klass:String,f:Callable) -> void:
	if node.is_class(klass):
		f.call(node)
	for c in node.get_children():
		apply_to_subtree(c,klass,f)

func _on_button_released(name: String) -> void:
	var rotate = func(m3d: MeshInstance3D):
		m3d.rotate_y(deg_to_rad(45))

	if name == "grip_click":
		if !voodoo_list.is_empty():
			var voodo =  voodoo_list[0].voodoo
			var origin = voodoo_list[0].origin
			#voodo.transform.basis = Basis(Vector3.UP, deg_to_rad(15)) * voodo.transform.basis
			var mouse_delta = Input.get_last_mouse_velocity()

			var yaw = Basis(Vector3.UP, -mouse_delta.x * 0.005)
			var pitch = Basis(Vector3.RIGHT, -mouse_delta.y * 0.005)

			var t = voodo.transform
			t.basis = yaw * pitch * t.basis
			voodo.transform = t 
			
			print(voodo.transform, " ", voodoo_list[0].origin.transform)
			
			origin.transform = voodo.transform
			
			#var current_basis = global_transform.basis
			#var delta_basis = current_basis * last_controller_basis.inverse()
#
			## Apply delta rotation to voodo
			#var t = voodo.transform
			#t.basis = delta_basis * t.basis
			#voodo.transform = t  # Set updated transform
			#voodo.freeze = false
			#apply_to_subtree(voodo,'MeshInstance3D',rotate)
			#print(voodoo_list[0].origin , "  ", voodoo_list[0].voodoo)
			#print("Okay is this working")
