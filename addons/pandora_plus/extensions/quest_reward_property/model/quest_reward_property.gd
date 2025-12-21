class_name PPQuestReward extends RefCounted

## Reward Property (Static)
## Represents immutable reward data, similar to PPQuestObjective
## Used to define rewards that can be granted to the player

## Reward Types
enum RewardType {
	ITEM,           ## Give item(s)
	CURRENCY,       ## Give gold/currency
	EXPERIENCE,     ## Give experience points
	UNLOCK_RECIPE,  ## Unlock a crafting recipe
	UNLOCK_QUEST,   ## Unlock another quest
	STAT_BOOST,     ## Permanent stat increase
	REPUTATION,     ## Increase faction reputation
	CUSTOM          ## Custom reward with script
}

var _reward_name: String
var _reward_type: int
var _reward_entity_reference: PandoraReference  ## For ITEM, UNLOCK_RECIPE, UNLOCK_QUEST
var _quantity: int
var _currency_amount: int
var _experience_amount: int
var _stat_name: String
var _stat_value: float
var _faction_name: String
var _reputation_amount: int
var _custom_script: String
var _optional: bool

## Constructor
func _init(
	reward_name: String = "",
	reward_type: int = RewardType.ITEM,
	reward_entity_reference: PandoraReference = null,
	quantity: int = 1,
	currency_amount: int = 0,
	experience_amount: int = 0,
	stat_name: String = "",
	stat_value: float = 0.0,
	faction_name: String = "",
	reputation_amount: int = 0,
	custom_script: String = "",
	optional: bool = false
) -> void:
	_reward_name = reward_name
	_reward_type = reward_type
	_reward_entity_reference = reward_entity_reference
	_quantity = quantity
	_currency_amount = currency_amount
	_experience_amount = experience_amount
	_stat_name = stat_name
	_stat_value = stat_value
	_faction_name = faction_name
	_reputation_amount = reputation_amount
	_custom_script = custom_script
	_optional = optional

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

func get_experience_amount() -> int:
	return _experience_amount

func get_stat_name() -> String:
	return _stat_name

func get_stat_value() -> float:
	return _stat_value

func get_faction_name() -> String:
	return _faction_name

func get_reputation_amount() -> int:
	return _reputation_amount

func get_custom_script() -> String:
	return _custom_script

func is_optional() -> bool:
	return _optional

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

func set_experience_amount(amount: int) -> void:
	_experience_amount = amount

func set_stat_name(stat_name: String) -> void:
	_stat_name = stat_name

func set_stat_value(value: float) -> void:
	_stat_value = value

func set_faction_name(faction_name: String) -> void:
	_faction_name = faction_name

func set_reputation_amount(amount: int) -> void:
	_reputation_amount = amount

func set_custom_script(script: String) -> void:
	_custom_script = script

func set_optional(optional: bool) -> void:
	_optional = optional

## Serialization (follows PPQuestObjective pattern)

func load_data(data: Dictionary) -> void:
	_reward_name = data.get("reward_name", "")
	_reward_type = data.get("reward_type", RewardType.ITEM)

	if data.has("reward_entity_reference"):
		var ref_data = data["reward_entity_reference"]
		_reward_entity_reference = PandoraReference.new(ref_data["_entity_id"], ref_data["_type"])

	_quantity = data.get("quantity", 1)
	_currency_amount = data.get("currency_amount", 0)
	_experience_amount = data.get("experience_amount", 0)
	_stat_name = data.get("stat_name", "")
	_stat_value = data.get("stat_value", 0.0)
	_faction_name = data.get("faction_name", "")
	_reputation_amount = data.get("reputation_amount", 0)
	_custom_script = data.get("custom_script", "")
	_optional = data.get("optional", false)

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
	var experience_field = find_field.call("Experience Amount")
	var stat_name_field = find_field.call("Stat Name")
	var stat_value_field = find_field.call("Stat Value")
	var faction_field = find_field.call("Faction Name")
	var reputation_field = find_field.call("Reputation Amount")
	var custom_script_field = find_field.call("Custom Script")
	var optional_field = find_field.call("Optional")

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
	if experience_field["enabled"]:
		result["experience_amount"] = _experience_amount
	if stat_name_field["enabled"]:
		result["stat_name"] = _stat_name
	if stat_value_field["enabled"]:
		result["stat_value"] = _stat_value
	if faction_field["enabled"]:
		result["faction_name"] = _faction_name
	if reputation_field["enabled"]:
		result["reputation_amount"] = _reputation_amount
	if custom_script_field["enabled"]:
		result["custom_script"] = _custom_script
	if optional_field.get("enabled", false):
		result["optional"] = _optional

	return result

func _to_string() -> String:
	return "<PPReward '%s'>" % _reward_name
