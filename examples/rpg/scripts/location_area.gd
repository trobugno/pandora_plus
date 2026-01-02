extends Area2D

@export var location: PPLocationEntity

signal location_reached(location_name: String)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		location_reached.emit(location.get_location_name())
