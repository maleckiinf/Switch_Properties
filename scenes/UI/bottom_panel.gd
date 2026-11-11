extends Control

@onready var spec_panels = [
	$WideBottom/spec_1,
	$WideBottom/spec_2,
	$WideBottom/spec_3
]

var specs: Array[String] = ["-", "-", "-"]

var gold_flag: int = 0


func _ready() -> void:
	update_gold_color()


func change_lab(specs) -> void:

	for i in range(spec_panels.size()):
		spec_panels[i].text = specs[i]

	update_gold_color()


func update_gold_color() -> void:

	for i in range(spec_panels.size()):

		if i == gold_flag:
			spec_panels[i].label_settings.font_color = Color.GOLD
		else:
			spec_panels[i].label_settings.font_color = Color.WHITE


func change_gold(direction: int) -> void:

	gold_flag = (gold_flag + direction + spec_panels.size()) % spec_panels.size()

	update_gold_color()
