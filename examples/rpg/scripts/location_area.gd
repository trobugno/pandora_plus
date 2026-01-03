extends Area2D

@export var location: PPLocationEntity

signal location_reached(location_entity: PPLocationEntity)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.current_location and body.current_location != location:
			body.current_location = location
			print("Reached ", location.get_location_name())
			location_reached.emit(location)
		else:
			body.current_location = location
