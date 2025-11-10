@tool
class_name PPRarityEntity extends PandoraEntity

func get_rarity_name() -> String:
	return get_string("name")

func get_percentage() -> float:
	return get_float("percentage")
