@tool
extends EditorPlugin

const ITEMS_NAME := "Items"
const RARITY_NAME := "Rarity"
const ITEM_RECIPES_NAME := "ItemRecipes"

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
	add_autoload_singleton("PPQuestUtils", "res://addons/pandora_plus/autoloads/PPQuestUtils.gd")
	add_autoload_singleton("PPNPCUtils", "res://addons/pandora_plus/autoloads/PPNPCUtils.gd")
	add_autoload_singleton("PPEquipmentUtils", "res://addons/pandora_plus/autoloads/PPEquipmentUtils.gd")

	# Register Managers
	add_autoload_singleton("PPPlayerManager", "res://addons/pandora_plus/managers/player_manager.gd")
	add_autoload_singleton("PPQuestManager", "res://addons/pandora_plus/managers/quest_manager.gd")
	add_autoload_singleton("PPNPCManager", "res://addons/pandora_plus/managers/npc_manager.gd")
	add_autoload_singleton("PPTimeManager", "res://addons/pandora_plus/managers/time_manager.gd")

	# Register Save System
	add_autoload_singleton("PPSaveManager", "res://addons/pandora_plus/save_system/save_manager.gd")

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
	remove_autoload_singleton("PPQuestUtils")
	remove_autoload_singleton("PPNPCUtils")
	remove_autoload_singleton("PPEquipmentUtils")

	# Unregister Managers
	remove_autoload_singleton("PPPlayerManager")
	remove_autoload_singleton("PPQuestManager")
	remove_autoload_singleton("PPNPCManager")
	remove_autoload_singleton("PPTimeManager")

	# Unregister Save System
	remove_autoload_singleton("PPSaveManager")

var _update_checker: Node = null

func _ready() -> void:
	PandoraPlusSettings.initialize()

	var rarity_category := _setup_rarity_categories()
	var item_category := _setup_item_categories(rarity_category)
	_setup_equipment_sub_categories(item_category)
	_setup_quest_categories()
	_setup_item_recipes_categories()
	var location_category := _setup_location_categories()
	_setup_npc_categories(location_category)

	# Save all data once after all categories have been created/verified.
	# This avoids intermediate saves that can cause side effects (file regeneration,
	# editor reimports) before sub-categories like Equipment are created,
	# which would prevent proper property inheritance from parent categories.
	Pandora.save_data()

	# Initialize update checker (non-blocking, deferred)
	call_deferred("_start_update_check")


func _start_update_check() -> void:
	var checker_script = load("res://addons/pandora_plus/update_system/pp_update_checker.gd")
	if checker_script == null:
		push_warning("Pandora+: Could not load update checker script")
		return
	_update_checker = checker_script.new()
	_update_checker.name = "PPUpdateChecker"
	_update_checker.set_meta("editor_plugin", self)
	add_child(_update_checker)

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
		rarity_category.set_generate_ids(true)
	else:
		rarity_category = rarity_categories[0]
		if not rarity_category.has_entity_property("name"):
			Pandora.create_property(rarity_category, "name", "String")
		if not rarity_category.has_entity_property("percentage"):
			Pandora.create_property(rarity_category, "percentage", "float")
		if not rarity_category.is_generate_ids():
			rarity_category.set_generate_ids(true)
	
	return rarity_category

func _setup_item_categories(rarity_category: PandoraCategory) -> PandoraCategory:
	const REFERENCE_TYPE = preload("uid://bs8pju4quv8m3")
	var all_categories = Pandora.get_all_categories()
	var item_category : PandoraCategory
	
	var item_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == ITEMS_NAME)
	
	# Create or update Items categories
	if not item_categories:
		item_category = Pandora.create_category(ITEMS_NAME)
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
		item_category.set_generate_ids(true)
	else:
		item_category = item_categories[0]
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
		if not item_category.is_generate_ids():
			item_category.set_generate_ids(true)
	
	return item_category

func _setup_quest_categories() -> void:
	const QUESTS_NAME := "Quests"

	var all_categories := Pandora.get_all_categories()

	# Create or update Quests category
	var quest_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == QUESTS_NAME)

	if not quest_categories:
		var quest_category = Pandora.create_category(QUESTS_NAME)
		quest_category.set_script_path("res://addons/pandora_plus/entities/quest_entity.gd")

		# Use the custom quest_property type which handles objectives and rewards internally
		Pandora.create_property(quest_category, "quest_data", "quest_property")
		quest_category.set_generate_ids(true)
	else:
		var quest_category : PandoraCategory = quest_categories[0]

		# Ensure all properties exist (for updates)
		if not quest_category.has_entity_property("quest_data"):
			Pandora.create_property(quest_category, "quest_data", "quest_property")
		if not quest_category.is_generate_ids():
			quest_category.set_generate_ids(true)

func _setup_location_categories() -> PandoraCategory:
	const LOCATIONS_NAME := "Locations"
	var all_categories := Pandora.get_all_categories()
	var location_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == LOCATIONS_NAME)
	var location_category : PandoraCategory

	# Create or update Locations category
	if not location_categories:
		location_category = Pandora.create_category(LOCATIONS_NAME)
		location_category.set_script_path("res://addons/pandora_plus/entities/location_entity.gd")

		# Basic properties
		Pandora.create_property(location_category, "name", "String")
		Pandora.create_property(location_category, "description", "String")
		Pandora.create_property(location_category, "texture", "resource")

		# Position properties
		Pandora.create_property(location_category, "position", "vector2")

		# Classification properties
		Pandora.create_property(location_category, "area_name", "String")
		Pandora.create_property(location_category, "location_type", "String")
		Pandora.create_property(location_category, "is_safe_zone", "bool")

		# Set default values
		location_category.get_entity_property("location_type").set_default_value("Wilderness")
		location_category.get_entity_property("is_safe_zone").set_default_value(false)
		
		location_category.set_generate_ids(true)
	else:
		location_category = location_categories[0]

		# Ensure all properties exist (for updates)
		if not location_category.has_entity_property("name"):
			Pandora.create_property(location_category, "name", "String")
		if not location_category.has_entity_property("description"):
			Pandora.create_property(location_category, "description", "String")
		if not location_category.has_entity_property("texture"):
			Pandora.create_property(location_category, "texture", "resource")
		if not location_category.has_entity_property("position"):
			Pandora.create_property(location_category, "position", "vector2")
		if not location_category.has_entity_property("area_name"):
			Pandora.create_property(location_category, "area_name", "String")
		if not location_category.has_entity_property("location_type"):
			Pandora.create_property(location_category, "location_type", "String")
		if not location_category.has_entity_property("is_safe_zone"):
			Pandora.create_property(location_category, "is_safe_zone", "bool")
		if not location_category.is_generate_ids():
			location_category.set_generate_ids(true)

	return location_category

func _setup_npc_categories(location_category: PandoraCategory) -> void:
	const NPCS_NAME := "NPCs"

	var all_categories := Pandora.get_all_categories()

	# Create or update NPCs category
	var npc_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == NPCS_NAME)

	if not npc_categories:
		var npc_category = Pandora.create_category(NPCS_NAME)
		npc_category.set_script_path("res://addons/pandora_plus/entities/npc_entity.gd")

		# Basic properties
		Pandora.create_property(npc_category, "name", "String")
		Pandora.create_property(npc_category, "description", "String")
		Pandora.create_property(npc_category, "texture", "resource")

		# Combat properties
		Pandora.create_property(npc_category, "base_stats", "stats_property")
		Pandora.create_property(npc_category, "faction", "String")
		Pandora.create_property(npc_category, "is_hostile", "bool")

		# Location properties
		const REFERENCE_TYPE = preload("uid://bs8pju4quv8m3")
		var spawn_location_property = Pandora.create_property(npc_category, "spawn_location", "reference")
		spawn_location_property.set_setting_override(REFERENCE_TYPE.SETTING_CATEGORY_FILTER, str(location_category._id))

		# Quest properties
		Pandora.create_property(npc_category, "quest_giver_for", "array")

		# Set default values
		npc_category.get_entity_property("faction").set_default_value("Neutral")
		npc_category.get_entity_property("is_hostile").set_default_value(false)
		
		npc_category.set_generate_ids(true)
	else:
		var npc_category : PandoraCategory = npc_categories[0]

		# Ensure all properties exist (for updates)
		if not npc_category.has_entity_property("name"):
			Pandora.create_property(npc_category, "name", "String")
		if not npc_category.has_entity_property("description"):
			Pandora.create_property(npc_category, "description", "String")
		if not npc_category.has_entity_property("texture"):
			Pandora.create_property(npc_category, "texture", "resource")
		if not npc_category.has_entity_property("base_stats"):
			Pandora.create_property(npc_category, "base_stats", "stats_property")
		if not npc_category.has_entity_property("faction"):
			Pandora.create_property(npc_category, "faction", "String")
		if not npc_category.has_entity_property("is_hostile"):
			Pandora.create_property(npc_category, "is_hostile", "bool")
		if not npc_category.has_entity_property("spawn_location"):
			const REFERENCE_TYPE = preload("uid://bs8pju4quv8m3")
			var spawn_location_property = Pandora.create_property(npc_category, "spawn_location", "reference")
			spawn_location_property.set_setting_override(REFERENCE_TYPE.SETTING_CATEGORY_FILTER, str(location_category._id))
		if not npc_category.has_entity_property("quest_giver_for"):
			Pandora.create_property(npc_category, "quest_giver_for", "array")
		if not npc_category.is_generate_ids():
			npc_category.set_generate_ids(true)

func _setup_equipment_sub_categories(item_category: PandoraCategory) -> void:
	const EQUIPMENT_NAME := "Equipment"
	const REFERENCE_TYPE = preload("uid://bs8pju4quv8m3")

	var all_categories := Pandora.get_all_categories()
	var all_sub_categories := Pandora.get_all_categories(item_category)
	var equipment_categories := all_sub_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == EQUIPMENT_NAME)

	if not equipment_categories:
		var equipment_category = Pandora.create_category(EQUIPMENT_NAME, item_category)
		equipment_category.set_script_path("res://addons/pandora_plus/entities/equipment_entity.gd")

		# Equipment-specific: slot type
		Pandora.create_property(equipment_category, "equipment_slot", "String")

		# Equipment-specific: stat bonuses
		Pandora.create_property(equipment_category, "stats_property", "stats_property")

		# Set defaults
		equipment_category.get_entity_property("equipment_slot").set_default_value("WEAPON")

		equipment_category.set_generate_ids(true)
	else:
		var equipment_category : PandoraCategory = equipment_categories[0]

		# Ensure all properties exist (for updates)
		if not equipment_category.has_entity_property("equipment_slot"):
			Pandora.create_property(equipment_category, "equipment_slot", "String")
		if not equipment_category.has_entity_property("stats_property"):
			Pandora.create_property(equipment_category, "stats_property", "stats_property")
		if not equipment_category.is_generate_ids():
			equipment_category.set_generate_ids(true)

func _setup_item_recipes_categories() -> void:
	var all_categories := Pandora.get_all_categories()
	var item_recipes_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == ITEM_RECIPES_NAME)

	if not item_recipes_categories:
		var item_recipes_category = Pandora.create_category(ITEM_RECIPES_NAME)
		item_recipes_category.set_script_path("res://addons/pandora_plus/entities/recipe_entity.gd")

		# Properties
		Pandora.create_property(item_recipes_category, "description", "String")
		Pandora.create_property(item_recipes_category, "recipe_property", "recipe_property")

		item_recipes_category.set_generate_ids(true)
	else:
		var item_recipes_category : PandoraCategory = item_recipes_categories[0]

		# Ensure all properties exist (for updates)
		if not item_recipes_category.has_entity_property("description"):
			Pandora.create_property(item_recipes_category, "description", "String")
		if not item_recipes_category.has_entity_property("recipe_property"):
			Pandora.create_property(item_recipes_category, "recipe_property", "recipe_property")
		if not item_recipes_category.is_generate_ids():
			item_recipes_category.set_generate_ids(true)
