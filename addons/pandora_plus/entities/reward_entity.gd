@tool
class_name PPRewardEntity extends PandoraEntity

## Reward Entity for Quest System
## Represents a reward given upon quest completion

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

func get_reward_type() -> int:
	return get_integer("reward_type")

func get_reward_entity() -> PandoraEntity:
	var ref = get_reference("reward_entity")
	return ref if ref else null

func get_quantity() -> int:
	return get_integer("quantity")

func get_currency_amount() -> int:
	return get_integer("currency_amount")

func get_experience_amount() -> int:
	return get_integer("experience_amount")

func get_stat_name() -> String:
	return get_string("stat_name")

func get_stat_value() -> float:
	return get_float("stat_value")

func get_faction_name() -> String:
	return get_string("faction_name")

func get_reputation_amount() -> int:
	return get_integer("reputation_amount")

func get_custom_script() -> String:
	return get_string("custom_script")

func is_optional() -> bool:
	return get_bool("optional")

func get_reward_name() -> String:
	return get_string("reward_name")

func get_icon() -> Texture:
	return get_resource("icon")
