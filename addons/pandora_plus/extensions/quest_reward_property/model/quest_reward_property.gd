class_name PPQuestReward extends RefCounted

## Reward Property (Static)
## Represents immutable reward data, similar to PPQuestObjective
## Used to define rewards that can be granted to the player

## Reward Types
enum RewardType {
	ITEM,           ## Give item(s)
	CURRENCY        ## Give gold/currency
}

var _reward_name: String
var _reward_type: int
var _reward_entity_reference: PandoraReference  ## For ITEM rewards
var _quantity: int
var _currency_amount: int

## Constructor
func _init(
	reward_name: String = "",
	reward_type: int = RewardType.ITEM,
	reward_entity_reference: PandoraReference = null,
	quantity: int = 1,
	currency_amount: int = 0
) -> void:
	_reward_name = reward_name
	_reward_type = reward_type
	_reward_entity_reference = reward_entity_reference
	_quantity = quantity
	_currency_amount = currency_amount

## Getters

func get_reward_name() -> String:
	return _reward_name

func get_reward_type() -> int:
	return _reward_type

func get_reward_entity_reference() -> PandoraReference:
	return _reward_entity_reference

func get_reward_entity() -> PandoraEntity:
	return _reward_entity_reference.get_entity() if _reward_entity_reference else null

func get_quantity() -> int:
	return _quantity

func get_currency_amount() -> int:
	return _currency_amount

## Setters

func set_reward_name(reward_name: String) -> void:
	_reward_name = reward_name

func set_reward_type(reward_type: int) -> void:
	_reward_type = reward_type

func set_reward_entity_reference(reference: PandoraReference) -> void:
	_reward_entity_reference = reference

func set_quantity(quantity: int) -> void:
	_quantity = quantity

func set_currency_amount(amount: int) -> void:
	_currency_amount = amount

## Serialization (follows PPQuestObjective pattern)

func load_data(data: Dictionary) -> void:
	_reward_name = data.get("reward_name", "")
	_reward_type = data.get("reward_type", RewardType.ITEM)

	if data.has("reward_entity_reference"):
		var ref_data = data["reward_entity_reference"]
		if ref_data is Dictionary and ref_data.has("_entity_id") and ref_data.has("_type"):
			_reward_entity_reference = PandoraReference.new(ref_data["_entity_id"], ref_data["_type"])
		else:
			_reward_entity_reference = null

	_quantity = data.get("quantity", 1)
	_currency_amount = data.get("currency_amount", 0)

func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}

	# Helper function to find field setting
	var find_field = func(name: String) -> Dictionary:
		var filtered = fields_settings.filter(func(d): return d["name"] == name)
		return filtered[0] if filtered.size() > 0 else {"enabled": false}

	var reward_name_field = find_field.call("Reward Name")
	var reward_type_field = find_field.call("Reward Type")
	var reward_entity_field = find_field.call("Reward Entity")
	var quantity_field = find_field.call("Quantity")
	var currency_field = find_field.call("Currency Amount")

	if reward_name_field["enabled"]:
		result["reward_name"] = _reward_name
	if reward_type_field["enabled"]:
		result["reward_type"] = _reward_type
	if reward_entity_field["enabled"] and _reward_entity_reference:
		result["reward_entity_reference"] = _reward_entity_reference.save_data()
	if quantity_field["enabled"]:
		result["quantity"] = _quantity
	if currency_field["enabled"]:
		result["currency_amount"] = _currency_amount

	return result

## Creates a deep copy of this reward
func duplicate() -> PPQuestReward:
	var entity_ref_copy: PandoraReference = null
	if _reward_entity_reference:
		entity_ref_copy = PandoraReference.new(_reward_entity_reference._entity_id, PandoraReference.Type.ENTITY)

	return PPQuestReward.new(
		_reward_name,
		_reward_type,
		entity_ref_copy,
		_quantity,
		_currency_amount
	)

func _to_string() -> String:
	return "<PPReward '%s'>" % _reward_name
