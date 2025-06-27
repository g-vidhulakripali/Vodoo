extends XROrigin3D

class_name XRBootstrap

@export var xr_interface_type: String = 'OpenXR'
@export var xr_debug_label: Label3D = null

enum PassthroughMode { NONE, DIRECT, BLENDMODE }

# cache the result
var has_passthrough:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# only OpenXR
	var xr_interface = XRServer.find_interface(xr_interface_type)
	
	# check if we have an XR interface
	if xr_interface and xr_interface.is_initialized():
		
		# switch on XR
		get_viewport().use_xr = true
		
		# if we can - passthrough should be on
		self.has_passthrough = XRBootstrap.enable_passthrough(xr_interface) != PassthroughMode.NONE
		
		# only switch on passthrough when XR interface is capable
		if has_passthrough:
			get_viewport().transparent_bg = true
			
	if xr_debug_label:
		xr_debug_label.text = "OpenXR: %s\nPassthrough:%s" % [get_viewport().use_xr,has_passthrough]


# from https://docs.godotengine.org/en/stable/tutorials/xr/openxr_passthrough.html    
static func enable_passthrough(xr_interface:XRInterface) -> PassthroughMode:
	if xr_interface: 
		if xr_interface.is_passthrough_supported():
			print("Device {} reports passthrough supported" % xr_interface.get_name())
			if xr_interface.start_passthrough():
				return PassthroughMode.DIRECT
		else:
			var modes = xr_interface.get_supported_environment_blend_modes()
			if xr_interface.XR_ENV_BLEND_MODE_ALPHA_BLEND in modes:
				xr_interface.set_environment_blend_mode(xr_interface.XR_ENV_BLEND_MODE_ALPHA_BLEND)
				return PassthroughMode.BLENDMODE
	return PassthroughMode.NONE
	
