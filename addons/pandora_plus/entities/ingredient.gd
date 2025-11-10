@tool
class_name PPIngredientEntity extends PandoraEntity

func get_item() -> PPItemEntity:
	return get_reference("item_type") as PPItemEntity

func get_quantity() -> int:
	return get_integer("quantity")
