extends Node2D

signal location_reached(location_entity: PPLocationEntity)

func _on_location_area_location_reached(location_entity: PPLocationEntity) -> void:
	location_reached.emit(location_entity)
