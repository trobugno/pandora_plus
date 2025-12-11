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
	
	const REFERENCE_TYPE = preload("uid://bs8pju4quv8m3")
	
	var all_categories = Pandora.get_all_categories()
	var rarity_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == RARITY_NAME)
	var item_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == ITEMS_NAME)
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
	
	# Create or update Items categories
	if not item_categories:
		var item_category = Pandora.create_category(ITEMS_NAME)
		item_category.set_script_path("res://addons/pandora_plus/entities/item_entity.gd")
		Pandora.create_property(item_category, "name", "String")
		Pandora.create_property(item_category, "description", "String")
		Pandora.create_property(item_category, "stackable", "bool")
		Pandora.create_property(item_category, "texture", "resource")
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
		if not item_category.has_entity_property("rarity"):
			var rarity_property = Pandora.create_property(item_category, "rarity", "reference")
			item_category.get_entity_property("rarity").set_default_value(rarity_category)
			rarity_property.set_setting_override(REFERENCE_TYPE.SETTING_CATEGORY_FILTER, str(rarity_category._id))
		Pandora.save_data()
