
# ProtoController v1.0 - Cleaned Version
# Based on Brackeys ProtoController
# CC0 License

extends CharacterBody3D

# ==================================================
# SETTINGS
# ==================================================

@export var can_move: bool = true
@export var has_gravity: bool = true
@export var can_jump: bool = true

@export_group("Speeds")
@export var look_speed: float = 0.002
@export var move_speed: float = 7.0
@export var jump_velocity: float = 4.5

@export_group("Input Actions")
@export var input_left: String = "ui_left"
@export var input_right: String = "ui_right"
@export var input_forward: String = "ui_up"
@export var input_back: String = "ui_down"
@export var input_jump: String = "ui_accept"

@export var switch_1: String = "switch_1"
@export var switch_2: String = "switch_2"
@export var switch_3: String = "switch_3"

@export var Left_switch: String = "Left_switch"
@export var Right_switch: String = "Right_switch"


# ==================================================
# REFERENCES
# ==================================================

@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var grabbed_anchor: Marker3D = $Head/SpringArm3D/GrabbedAnchor
@onready var object_grabber_shape_cast: ShapeCast3D = $Head/ObjectGrabberShapeCast
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var omni_light_3d: OmniLight3D = $MeshInstance3D/OmniLight3D
@onready var raycast :RayCast3D = $RayCast3D


# ==================================================
# PLAYER VARIABLES
# ==================================================

var mouse_captured: bool = false
var look_rotation: Vector2
var first_change_label_emit = true

# ==================================================
# OBJECT VARIABLES
# ==================================================

var grabbed_object: RigidBody3D = null

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
var gold_flag: int = 0

# ==================================================
# SIGNALS
# ==================================================

signal change_box(target: RigidBody3D, spec: String, type_con: int)
signal change_label(specs)
signal change_gold(direction : int)

# ==================================================
# INITIALIZATION
# ==================================================

func _ready() -> void:
	print(specs)
	check_input_mappings()
	
	# Create unique material instance
	var material := mesh.get_active_material(0)

	if material is StandardMaterial3D:
		var unique_material := material.duplicate() as StandardMaterial3D
		mesh.set_surface_override_material(0, unique_material)
	
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	
	
	

# ==================================================
# INPUT
# ==================================================

func _unhandled_input(event: InputEvent) -> void:

	# Mouse capture
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()

	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()

	# Mouse look
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)

	# Object interaction
	if Input.is_action_just_pressed("interact"):
		if grabbed_object:
			grabbed_object = null
		else:
			try_grab_object()

	# Throw object
	if Input.is_action_just_pressed("interact2"):
		if grabbed_object:
			throw_object()

	# Switch 1
	if Input.is_action_just_pressed(switch_1):
		change_box_emit(0)
		change_label_gold_emit(0)

	# Switch 2
	if Input.is_action_just_pressed(switch_2):
		change_box_emit(1)
		change_label_gold_emit(0)

	# Switch 3
	if Input.is_action_just_pressed(switch_3):
		change_box_emit(2)
		change_label_gold_emit(0)

	# Left switch
	if Input.is_action_just_pressed(Left_switch):
		change_label_gold_emit(-1)

	# Right switch
	if Input.is_action_just_pressed(Right_switch):
		change_label_gold_emit(+1)
		
func change_box_emit(switch: int) -> void:
	if grabbed_object:
		if gold_flag == 0:
			change_box.emit(grabbed_object, specs[0], switch)
		if gold_flag == 1:
			change_box.emit(grabbed_object, specs[1], switch)
		if gold_flag == 2:
			change_box.emit(grabbed_object, specs[2], switch)

func change_label_gold_emit(direction: int) -> void:
	change_gold.emit(direction)
	gold_flag = (gold_flag + direction + 3) % 3
	change_label.emit(specs)



# ==================================================
# OBJECT INTERACTION
# ==================================================

func try_grab_object() -> void:

	if not object_grabber_shape_cast.is_colliding():
		return

	var collided = object_grabber_shape_cast.get_collider(0)

	if collided is RigidBody3D:
		grabbed_object = collided


func throw_object() -> void:

	if not is_instance_valid(grabbed_object):
		grabbed_object = null
		return

	grabbed_object.apply_impulse(
		(-head.global_basis.z * 5.0) + Vector3(0.0, 2.0, 0.0)
	)

	grabbed_object = null


# ==================================================
# OBJECT PROPERTIES
# ==================================================

func set_ob(spec_new: String) -> void:
	
	var spec_old: String
	
	spec_old = specs.get(gold_flag)
	specs.set(gold_flag, spec_new)
		
	ob_size = 1.0
	ob_glow = 0
	ob_bounce = 0
	ob_pink = 0
	ob_gravity = 0
	ob_size_multiply = 0
	ob_size_divide = 0
	
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
		
		
	# GRAVITY
	if ob_gravity:
		can_move = false
		can_jump = false
	else:
		can_move = true
		can_jump = true
		
		
	#BOUNCE
	if ob_bounce:
		jump_velocity = 9.0
	else:
		jump_velocity = 4.5
		
		
	# SIZE
	var ob_size_difference: float = (ob_size_multiply - ob_size_divide)
	
	ob_size_difference = (2 ** ob_size_difference) * 1.8
	collider.shape.height = ob_size_difference
	#$Head.position = Vector3( 0.0, ob_size_difference, 0.0)
	#$Head/SpringArm3D.spring_length = ob_size_difference * 1.5
	
	if collider.shape.height < 1.8:
		$Head.position = Vector3( 0.0, 1.8, 0.0)
	elif collider.shape.height > 1.8:
		$Head.position = Vector3( 0.0, 1.8, 0.0)
	elif collider.shape.height > 0.9:
		$Head.position = Vector3( 0.0, 1.8, 0.0)

	print($Head.position)
	print(collider.shape.height)
		
	
	if material is StandardMaterial3D:
		material.albedo_color = ob_color
		material.emission = ob_color
		omni_light_3d.light_color = ob_color
		

# ==================================================
# PHYSICS
# ==================================================

func _physics_process(delta: float) -> void:
	
	if first_change_label_emit:
		print(specs)
		change_label.emit(specs)
		first_change_label_emit = false
	
	# Gravity
	if has_gravity and not is_on_floor():
		velocity += get_gravity() * delta

	# Jumping
	if can_jump and Input.is_action_just_pressed(input_jump) and is_on_floor():
		velocity.y = jump_velocity

	# Movement
	if can_move:
		var input_dir := Input.get_vector(
			input_left,
			input_right,
			input_forward,
			input_back
		)

		var move_dir := (
				global_transform.basis.orthonormalized()
				* Vector3(input_dir.x, 0.0, input_dir.y)
			).normalized()

		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0.0, move_speed)
			velocity.z = move_toward(velocity.z, 0.0, move_speed)

	else:
		velocity.x = 0.0
		velocity.z = 0.0

	# Apply movement
	move_and_slide()

	# Move grabbed object
	update_grabbed_object(delta)

	# Push rigid bodies
	push_rigid_bodies()


# ==================================================
# GRABBED OBJECT PHYSICS
# ==================================================

func update_grabbed_object(delta: float) -> void:

	if not is_instance_valid(grabbed_object):
		grabbed_object = null
		return

	var target_pos: Vector3 = grabbed_anchor.global_position
	var current_pos: Vector3 = grabbed_object.global_position

	var direction: Vector3 = target_pos - current_pos
	var required_velocity: Vector3 = direction / delta

	grabbed_object.linear_velocity = required_velocity
	grabbed_object.angular_velocity *= 0.1


# ==================================================
# RIGID BODY PUSHING
# ==================================================

func push_rigid_bodies() -> void:
	
	if not raycast.get_collider():
		for i in get_slide_collision_count():
			var collision := get_slide_collision(i)
			var collided_body = collision.get_collider()

			if collided_body is RigidBody3D:
				var push_direction := -collision.get_normal()
				push_direction.y = 0.0
				push_direction = push_direction.normalized()

				collided_body.apply_central_impulse(
					push_direction * 0.5
				)


# ==================================================
# CAMERA LOOK
# ==================================================

func rotate_look(rot_input: Vector2) -> void:

	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(
		look_rotation.x,
		deg_to_rad(-85.0),
		deg_to_rad(85.0)
	)

	look_rotation.y -= rot_input.x * look_speed

	transform.basis = Basis()
	rotate_y(look_rotation.y)

	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


# ==================================================
# MOUSE CONTROL
# ==================================================

func capture_mouse() -> void:

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse() -> void:

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


# ==================================================
# INPUT VALIDATION
# ==================================================

func check_input_mappings() -> void:

	if can_move:
		var movement_actions = [
			input_left,
			input_right,
			input_forward,
			input_back
		]

		for action in movement_actions:
			if not InputMap.has_action(action):
				push_error(
					"Movement disabled. Missing Input Action: " + action
				)
				can_move = false
				break

	if can_jump and not InputMap.has_action(input_jump):
		push_error(
			"Jumping disabled. Missing Input Action: " + input_jump
		)
		can_jump = false
