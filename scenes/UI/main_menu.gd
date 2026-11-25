extends Node2D

var speed_rotation_cube = 0.1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Box.rotate_y(speed_rotation_cube * delta)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_01.tscn")


func _on_levels_pressed() -> void:
	print("_on_levels_pressed")


func _on_options_pressed() -> void:
	print("_on_options_pressed")


func _on_quit_pressed() -> void:
	get_tree().quit()
