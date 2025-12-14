@tool
class_name PPItemEntity extends PandoraEntity

func get_item_name() -> String:
	return get_string("name")

func get_description() -> String:
	return get_string("description")

func get_texture() -> Texture:
	return get_resource("texture")

func is_stackable() -> bool:
	return get_bool("stackable")

func get_rarity() -> PPRarityEntity:
	return get_reference("rarity") as PPRarityEntity

func get_value() -> float:
	return get_float("value")

func get_weight() -> float:
	return get_float("weight")
