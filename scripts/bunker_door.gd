
extends StaticBody3D


# ==================================================
# SETTINGS
# ==================================================

var is_open: bool = false
var bodies_entered: int = 0


# ==================================================
# REFERENCES
# ==================================================

@onready var door_animation: AnimationPlayer = $"Door Animation"


# ==================================================
# DOOR CONTROL
# ==================================================

func open_door() -> void:

	if is_open:
		return

	is_open = true
	door_animation.play("open")


func close_door() -> void:

	if not is_open:
		return

	is_open = false
	door_animation.play_backwards("open")


# ==================================================
# PRESSURE PLATE
# ==================================================

func enter_trigger() -> void:

	bodies_entered += 1

	if bodies_entered == 1:
		open_door()


func exit_trigger() -> void:

	bodies_entered = maxi(0, bodies_entered - 1)

	if bodies_entered == 0:
		close_door()


# ==================================================
# SIGNALS
# ==================================================

func _on_pressure_plate_body_shape_entered(
	_body_rid: RID,
	_body: Node3D,
	_body_shape_index: int,
	_local_shape_index: int
) -> void:

	enter_trigger()


func _on_pressure_plate_body_shape_exited(
	_body_rid: RID,
	_body: Node3D,
	_body_shape_index: int,
	_local_shape_index: int
) -> void:

	exit_trigger()
