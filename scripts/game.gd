
extends Node3D


# ==================================================
# REFERENCES
# ==================================================

@onready var proto_controller: CharacterBody3D = $Entities/ProtoController

@onready var rigid_box: RigidBox = $Entities/RigidBox
@onready var rigid_box2: RigidBox = $Entities/RigidBox2
@onready var rigid_box3: RigidBox = $Entities/RigidBox3
@onready var rigid_box4: RigidBox = $Entities/RigidBox4
@onready var rigid_box5: RigidBox = $Entities/RigidBox5
@onready var rigid_box6: RigidBox = $Entities/RigidBox6

@onready var bottom_panel: Control = $UI/BottomPanel


# ==================================================
# INITIALIZATION
# ==================================================

func _ready() -> void:

	# Player signals
	proto_controller.change_box.connect(_on_change_box)
	proto_controller.change_label.connect(_on_change_label)
	proto_controller.change_gold.connect(_on_change_gold)
	
	# Box signals
	var boxes = get_tree().get_nodes_in_group("rigid_boxes")

	for box in boxes:
		if box is RigidBox:
			box.change_proto.connect(_on_change_proto)


# ==================================================
# PLAYER -> BOX
# ==================================================

func _on_change_box(target: RigidBody3D, property: String, type_con: int) -> void:

	if not is_instance_valid(target):
		return

	if target is RigidBox:
		target.set_ob(property, type_con)


# ==================================================
# BOX -> PLAYER
# ==================================================

func _on_change_proto(property: String) -> void:
	proto_controller.set_ob(property)


# ==================================================
# PLAYER -> UI
# ==================================================

func _on_change_label( property_Array) -> void:
	
	bottom_panel.change_lab( property_Array)


func _on_change_gold(direction : int) -> void:
	
	bottom_panel.change_gold(direction)
