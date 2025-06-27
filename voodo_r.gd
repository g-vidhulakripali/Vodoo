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

class Voodoo:
	var origin : Node3D
	var voodoo : Node3D

var voodoo_list : Array[Voodoo] = []

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
		#if collider.is_in_group("Pickable"):
			#pass
			##print("This is a pickable group", collider.name)
			#
		#if collider:
			#pass
			#print("Pickable detected", collider.name)
		
		#if collider.is_in_group("Pickable"):
			#mesh_instance = find_mesh_recursive(collider)
			#if mesh_instance and voodoo_left_mesh:
				#pass
				##voodoo_left_mesh.mesh = mesh_instance.mesh
				##print("Voodoo mesh updated to:", mesh_instance.name)
			#else:
				#floating_prompt.visible = false
				#print("Could not find MeshInstance3D in collider or voodoo_left_mesh is missing")

			

				#voodoo_left_mesh.mesh = mesh_instance.mesh
			#voodoo_left_mesh.mesh = collider.mesh
			#var mesh_child = collider.get_node_or_null("MeshInstance3D")
			#voodoo_left_mesh.mesh = mesh_child.mesh
			
			#var mesh_child =  collider.find_child("" , true, false)
	#
			#voodoo_left_mesh.mesh = mesh_instance.mesh
			#print("The voddo is cloned",mesh_child.name)
			
			#voodoo_left_mesh.override = collider.material.override
	else:
		floating_prompt.text = "Select"
		isClicked = false
				
		
	#var start = ray_cast.global_transform.origin
	#var end = start+ray_cast.global_transform.basis.z* -ray_cast.target_position.length()
	#var st = SurfaceTool.new()
	#st.begin(Mesh.PRIMITIVE_LINES)
	#st.set_color(Color.RED)
	#st.add_vertex(start)
	#st.add_vertex(end)
	
	
	#var mesh = st.commit()
	#ray_visual.mesh = mesh

func find_mesh_recursive(node: Node) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
		var found = find_mesh_recursive(child)
		if found:
			return found
	return null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("simulate_trigger"):
		_on_button_pressed("trigger_click")


func _on_button_pressed(name: String) -> void:
	var isClicked = false
	var highlight_mat = func (m3d : MeshInstance3D):
		m3d.material_override = override_material
	var scaling = func (m3d: MeshInstance3D):
		m3d.transform.scaled(Vector3(0.1,0.1,0.1))
	if name == "trigger_click":
		if !voodo_enabled.is_empty():
			holder.remove_child(voodo_enabled[0])
			voodo_enabled.clear()
		#print(voodo_enabled[0].name  + " on button clicked")
		if collider and  collider.is_in_group("Pickable"):
			print(collider.name + " collider vodo ", voodo_enabled)
			cloned_instance = collider.duplicate(true)
			if voodo_enabled.is_empty():
				voodo_enabled.append(cloned_instance)
				holder.add_child(voodo_enabled[0])
				print("Is it working? " , voodo_enabled)
				apply_to_subtree(voodo_enabled[0],'MeshInstance3D',highlight_mat)
				voodo_enabled[0].global_scale(Vector3(0.5,0.5,0.5))
				#voodo_enabled[0].global_translate(holder.global_position)
			#holder.add_child(cloned_instance)
			#voodoo_left_mesh.add_child(voodo_enabled[0].duplicate())
		#if collider.is_in_group("Pickable"):
			#mesh_instance = find_mesh_recursive(collider)
			#if mesh_instance and voodoo_left_mesh:
				#voodoo_left_mesh.mesh = mesh_instance.mesh
				##print("Voodoo mesh updated to:", mesh_instance.name)
			#else:
				#print("Here")
				#floating_prompt.visible = false
			
			
		
	if !isClicked:
		print("fhjshfdhjk")
		print(default_mesh)
		voodoo_left_mesh.mesh = default_mesh.mesh
		
		
 # Replace with function body.
static func apply_to_subtree(node:Node,klass:String,f:Callable) -> void:
	if node.is_class(klass):
		f.call(node)
	for c in node.get_children():
		apply_to_subtree(c,klass,f)
