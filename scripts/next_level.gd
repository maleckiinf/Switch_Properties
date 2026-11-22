extends Area3D

var current_level:String
var next_number:int
var next_level:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_level = str(get_tree().current_scene).left(7).right(1)
	next_number = int(current_level) + 1
	$AudioStreamPlayer3D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	
	get_tree().change_scene_to_file("res://scenes/levels/level_0" + str(next_number) + ".tscn")
