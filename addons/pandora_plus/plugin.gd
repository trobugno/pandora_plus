@tool
extends EditorPlugin

const ITEMS_NAME := "Items"
const RARITY_NAME := "Rarity"

func _enable_plugin() -> void:
	var editor_config_plugins = ProjectSettings.get_setting("editor_plugins/enabled")
	if editor_config_plugins == null:
		push_error("Pandora is not installed. Please make sure you enable Pandora before using Pandora+")
	else:
		var plugins = editor_config_plugins as Array
		if not plugins.has("res://addons/pandora/plugin.cfg"):
			push_error("Pandora is not installed or enabled. Please make sure you enable Pandora before using Pandora+")
		else:
			var extensions_dir : Array = []
			for exdir in PandoraSettings.get_extensions_dirs():
				extensions_dir.append(exdir)
			extensions_dir.append(&"res://addons/pandora_plus/extensions")
			PandoraSettings.set_extensions_dir(extensions_dir)
	
	# Register Utils Autoloaders
	add_autoload_singleton("PPCombatCalculator", "res://addons/pandora_plus/autoloads/PPCombatCalculator.gd")
	add_autoload_singleton("PPInventoryUtils", "res://addons/pandora_plus/autoloads/PPInventoryUtils.gd")
	add_autoload_singleton("PPRecipeUtils", "res://addons/pandora_plus/autoloads/PPRecipeUtils.gd")

func _disable_plugin() -> void:
	var extensions_dir : Array = []
	for exdir in PandoraSettings.get_extensions_dirs():
		extensions_dir.append(exdir)
	extensions_dir.erase(&"res://addons/pandora_plus/extensions")
	PandoraSettings.set_extensions_dir(extensions_dir)
	
	# Unregister Utils Autoloaders
	remove_autoload_singleton("PPCombatCalculator")
	remove_autoload_singleton("PPInventoryUtils")
	remove_autoload_singleton("PPRecipeUtils")

func _ready() -> void:
	PandoraPlusSettings.initialize()
	
	var rarity_category := _setup_rarity_categories()
	_setup_item_categories(rarity_category)
	_setup_quest_categories()

func _setup_rarity_categories() -> PandoraCategory:
	var all_categories = Pandora.get_all_categories()
	var rarity_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == RARITY_NAME)
	var rarity_category : PandoraCategory
	
	# Create or update Rarity categories
	if not rarity_categories:
		rarity_category = Pandora.create_category(RARITY_NAME)
		rarity_category.set_script_path("res://addons/pandora_plus/entities/rarity_entity.gd")
		Pandora.create_property(rarity_category, "name", "String")
		Pandora.create_property(rarity_category, "percentage", "float")
		Pandora.save_data()
	else:
		rarity_category = rarity_categories[0]
		if not rarity_category.has_entity_property("name"):
			Pandora.create_property(rarity_category, "name", "String")
		if not rarity_category.has_entity_property("percentage"):
			Pandora.create_property(rarity_category, "percentage", "float")
		Pandora.save_data()
	
	return rarity_category

func _setup_item_categories(rarity_category: PandoraCategory) -> void:
	const REFERENCE_TYPE = preload("uid://bs8pju4quv8m3")
	var all_categories = Pandora.get_all_categories()
	
	var item_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == ITEMS_NAME)
	
	# Create or update Items categories
	if not item_categories:
		var item_category = Pandora.create_category(ITEMS_NAME)
		item_category.set_script_path("res://addons/pandora_plus/entities/item_entity.gd")
		Pandora.create_property(item_category, "name", "String")
		Pandora.create_property(item_category, "description", "String")
		Pandora.create_property(item_category, "stackable", "bool")
		Pandora.create_property(item_category, "texture", "resource")
		Pandora.create_property(item_category, "value", "float")
		Pandora.create_property(item_category, "weight", "float")
		var rarity_property = Pandora.create_property(item_category, "rarity", "reference")
		item_category.get_entity_property("rarity").set_default_value(rarity_category)
		rarity_property.set_setting_override(REFERENCE_TYPE.SETTING_CATEGORY_FILTER, str(rarity_category._id))
		Pandora.save_data()
	else:
		var item_category : PandoraCategory = item_categories[0]
		if not item_category.has_entity_property("name"):
			Pandora.create_property(item_category, "name", "String")
		if not item_category.has_entity_property("description"):
			Pandora.create_property(item_category, "description", "String")
		if not item_category.has_entity_property("stackable"):
			Pandora.create_property(item_category, "stackable", "bool")
		if not item_category.has_entity_property("texture"):
			Pandora.create_property(item_category, "texture", "resource")
		if not item_category.has_entity_property("value"):
			Pandora.create_property(item_category, "value", "float")
		if not item_category.has_entity_property("weight"):
			Pandora.create_property(item_category, "weight", "float")
		if not item_category.has_entity_property("rarity"):
			var rarity_property = Pandora.create_property(item_category, "rarity", "reference")
			item_category.get_entity_property("rarity").set_default_value(rarity_category)
			rarity_property.set_setting_override(REFERENCE_TYPE.SETTING_CATEGORY_FILTER, str(rarity_category._id))
		Pandora.save_data()

func _setup_quest_categories() -> void:
	const QUESTS_NAME := "Quests"
	const OBJECTIVES_NAME := "Quest Objectives"
	const REWARDS_NAME := "Quest Rewards"
	
	var all_categories := Pandora.get_all_categories()
	
	# Create or update Quests category
	var quest_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == QUESTS_NAME)
	
	if not quest_categories:
		var quest_category = Pandora.create_category(QUESTS_NAME)
		quest_category.set_script_path("res://addons/pandora_plus/entities/quest_entity.gd")
		
		# Quest properties
		Pandora.create_property(quest_category, "quest_id", "String")
		Pandora.create_property(quest_category, "quest_name", "String")
		Pandora.create_property(quest_category, "description", "String")
		Pandora.create_property(quest_category, "quest_type", "int")
		Pandora.create_property(quest_category, "objectives", "array")
		Pandora.create_property(quest_category, "rewards", "array")
		Pandora.create_property(quest_category, "prerequisites", "array")
		Pandora.create_property(quest_category, "level_requirement", "int")
		Pandora.create_property(quest_category, "auto_complete", "bool")
		Pandora.create_property(quest_category, "time_limit", "float")
		Pandora.create_property(quest_category, "quest_giver", "reference")
		Pandora.create_property(quest_category, "hidden", "bool")
		Pandora.create_property(quest_category, "category", "String")
		Pandora.create_property(quest_category, "icon", "resource")
		
		Pandora.save_data()
	
	# Create or update Quest Objectives category
	var objective_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == OBJECTIVES_NAME)
	
	if not objective_categories:
		var objective_category = Pandora.create_category(OBJECTIVES_NAME)
		objective_category.set_script_path("res://addons/pandora_plus/entities/objective_entity.gd")
		
		Pandora.create_property(objective_category, "objective_id", "String")
		Pandora.create_property(objective_category, "objective_type", "int")
		Pandora.create_property(objective_category, "description", "String")
		Pandora.create_property(objective_category, "target_entity", "reference")
		Pandora.create_property(objective_category, "target_quantity", "int")
		Pandora.create_property(objective_category, "optional", "bool")
		Pandora.create_property(objective_category, "hidden", "bool")
		Pandora.create_property(objective_category, "custom_script", "String")
		Pandora.create_property(objective_category, "order_index", "int")
		Pandora.create_property(objective_category, "sequential", "bool")
		
		Pandora.save_data()
	
	# Create or update Quest Rewards category
	var reward_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == REWARDS_NAME)
	
	if not reward_categories:
		var reward_category = Pandora.create_category(REWARDS_NAME)
		reward_category.set_script_path("res://addons/pandora_plus/entities/reward_entity.gd")
		
		Pandora.create_property(reward_category, "reward_type", "int")
		Pandora.create_property(reward_category, "reward_entity", "reference")
		Pandora.create_property(reward_category, "quantity", "int")
		Pandora.create_property(reward_category, "currency_amount", "int")
		Pandora.create_property(reward_category, "experience_amount", "int")
		Pandora.create_property(reward_category, "stat_name", "String")
		Pandora.create_property(reward_category, "stat_value", "float")
		Pandora.create_property(reward_category, "faction_name", "String")
		Pandora.create_property(reward_category, "reputation_amount", "int")
		Pandora.create_property(reward_category, "custom_script", "String")
		Pandora.create_property(reward_category, "optional", "bool")
		Pandora.create_property(reward_category, "reward_name", "String")
		Pandora.create_property(reward_category, "icon", "resource")
		
		Pandora.save_data()
