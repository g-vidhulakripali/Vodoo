extends Node3D
@export var VoodooInteraction:Node3D = null
var voodooEnabled : Array[Node3D]
class Voodoo:
	var origin: Node3D
	var output: Node3D
var voodoMap : Array[Voodoo]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in get_children():
		if c.is_in_group("Voodoo_Technique"):
			print(c.name)
			voodooEnabled.append(c)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if not voodooEnabled.is_empty():
			var clone := voodooEnabled[0].duplicate() as Node3D
			VoodooInteraction.add_child(clone)
			var vc=Voodoo.new()
			vc.origin=voodooEnabled[0]
			vc.output=clone
			voodoMap.append(vc)
			print("Clone Created")
	
