extends Area3D

@onready var red: MeshInstance3D = $red
@onready var black: MeshInstance3D = $black


var body_counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#red = red.duplicate() # Not necessary if only material is shared
	var material = red.get_active_material(0).duplicate()
	red.set_surface_override_material(0, material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	body_counter += 1
	is_pressure_plate_empty( body_counter)


func _on_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	body_counter -= 1
	is_pressure_plate_empty( body_counter)
	
	
func is_pressure_plate_empty( number_of_bodies: int):
	if number_of_bodies <= 0:
		red.get_active_material(0).albedo_color = Color.RED
	else:
		red.get_active_material(0).albedo_color = Color.GREEN
