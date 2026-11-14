
extends RigidBody3D
class_name RigidBox


# ==================================================
# REFERENCES
# ==================================================

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var label: Label3D = $Label3D
@onready var omni_light_3d: OmniLight3D = $MeshInstance3D/OmniLight3D


# ==================================================
# OBJECT PROPERTIES
# ==================================================

var ob_size: float = 1.0
var ob_weight: float = 1.0

var ob_glow: int = 0
var ob_bounce: int = 0
var ob_pink: int = 0
var ob_gravity: int = 0
var ob_reflective: int = 0
var ob_magnetic_plus: int = 0
var ob_magnetic_minus: int = 0
var ob_size_multiply: int = 0
var ob_size_divide: int = 0

var ob_color: Color = Color.ORANGE

@export var specs: Array[String] = ["-", "-", "-"]


# ==================================================
# SIGNALS
# ==================================================

signal change_proto( specs)


# ==================================================
# INITIALIZATION
# ==================================================

func _ready() -> void:
	
	# Initialize label
	label.text = specs.get(0)

	# Create unique material instance
	var material := mesh.get_active_material(0)

	if material is StandardMaterial3D:
		var unique_material := material.duplicate() as StandardMaterial3D
		mesh.set_surface_override_material(0, unique_material)
		
	for i in specs:
		update_spec(i)

	# Apply initial properties
	update_appearance()


# ==================================================
# OBJECT PROPERTIES
# ==================================================

func set_ob(spec_new: String, type_con: int) -> void:
	
	var spec_old: String
	
	spec_old = specs.get(type_con)
	specs.set(type_con, spec_new)
	
	# Notify connected character
	change_proto.emit(spec_old)
	
	ob_size = 1.0
	ob_glow = 0
	ob_bounce = 0
	ob_pink = 0
	ob_gravity = 0
	ob_size_multiply = 0
	ob_size_divide = 0
	
	mass = ob_size * ob_size
	
	for i in specs:
		update_spec(i)

	# Update appearance
	update_appearance()


func update_spec( spec: String) -> void:
	match spec:
		"GLOW":
			ob_glow += 1 
			
		"BOUNCE":
			ob_bounce += 1 	
		
		"PINK":
			ob_pink += 1 
			
		"GRAVITY":
			ob_gravity += 1 
			
		"SIZE_MULTIPLY":
			ob_size_multiply += 1
			
		"SIZE_DIVIDE":
			ob_size_divide += 1

# ==================================================
# VISUALS
# ==================================================

func update_appearance() -> void:

	# Update material
	var material := mesh.get_surface_override_material(0)

	# PINK
	if ob_pink == 1:
		ob_color = Color.PINK
	elif ob_pink == 2:
		ob_color = Color.HOT_PINK
	elif ob_pink == 3:
		ob_color = Color.DEEP_PINK
	else:
		ob_color = Color.ORANGE
	
	# GLOW
	var vector_glow = ob_glow * 2
	omni_light_3d.light_energy = vector_glow
	omni_light_3d.omni_range = vector_glow * 2
	if ob_glow >= 1:
		material.emission_enabled = true
	else:
		material.emission_enabled = false
		
	# BOUNCE
	var vector_bounce = ob_bounce * 0.5
	physics_material_override.bounce = vector_bounce
		
	# GRAVITY
	if ob_gravity:
		custom_integrator = true
	else:
		custom_integrator = false
		
	
	# SIZE
	var ob_size_difference: float = (ob_size_multiply - ob_size_divide)
	ob_size = 2 ** ob_size_difference
	scale = Vector3( ob_size, ob_size, ob_size)
	mass = ob_size * ob_size

	if material is StandardMaterial3D:
		material.albedo_color = ob_color
		material.emission = ob_color
		omni_light_3d.light_color = ob_color
		

	# Update label
	label.text = specs.get(0)
	label.text += "  "
	label.text += specs.get(1)
	label.text += "  "
	label.text += specs.get(2)
