class_name UINotification extends PanelContainer

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel

func _ready() -> void:
	hide()

func show_up(title: String, description: String) -> void:
	title_label.text = title
	description_label.text = description
	show()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 1.5).set_delay(5)
	await tween.finished
	queue_free()
