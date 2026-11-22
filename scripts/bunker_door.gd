extends Node3D

var is_open := false
@onready var door_animation: AnimationPlayer = $"Door Animation"

func _process(_delta: float) -> void:

	var plates = get_tree().get_nodes_in_group("pressure_plates")

	if plates.is_empty():
		close_door()
		return

	for plate in plates:

		if not plate.is_pressed:
			close_door()
			return

	open_door()
	
	


func open_door() -> void:
	if is_open:
		return
	
	is_open = true
	$AudioStreamPlayer3D.play()
	door_animation.play("open")
	
func close_door() -> void:
	if not is_open:
		return

	is_open = false
	$AudioStreamPlayer3D.play()
	door_animation.play_backwards("open")
