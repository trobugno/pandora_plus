# Pandora+ Documentation

Welcome to the **Pandora+** documentation! This comprehensive guide will help you build production-ready RPG systems for Godot Engine.

## 🎯 What is Pandora+?

Pandora+ extends [Pandora by BitBrain](https://github.com/bitbrain/pandora) with specialized RPG-oriented data properties and runtime systems. It provides everything you need to create complex RPG mechanics without reinventing the wheel.

## ✨ Key Features

### 📊 Runtime Stats System
Dynamic stat calculation with support for temporary and permanent modifiers. Perfect for buffs, debuffs, equipment bonuses, and level-up systems.

```gdscript
var runtime_stats := PPRuntimeStats.new(base_stats)
var buff := PPStatModifier.create_percent("attack", 50.0, "potion", 60.0)
runtime_stats.add_modifier(buff)
```

[Learn more →](core-systems/runtime-stats.md)

### 📓 Recipe System
Want to create crafting recipes? Potions? Anything that can be created by combining items? Then the Recipe system is for you!

```gdscript
var wood := Pandora.get_entity(EntityIds.WOOD) as PPItemEntity
var stone := Pandora.get_entity(EntityIds.STONE) as PPItemEntity
var sword := Pandora.get_entity(EntityIds.STONE_SWORD) as PPItemEntity

var wood_ingredient := PPIngredient.new(.., ..)
var stone_ingredient := PPIngredient.new(.., ..)
var sword_result = PandoraReference.new(.., ..)

var ingredients := [wood_ingredient, stone_ingredient]
var recipe := PPRecipe.new(ingredients, sword_result, 0, "CRAFTING")

if PPRecipeUtils.can_craft(player_inventory, recipe):
    PPRecipeUtils.craft_recipe(player_inventory, recipe)
```
At the end of the process, the used items will **automatically** disappear from your inventory and the newly created one will appear!

[Learn more →](core-systems/recipe.md)

### 🎒 Inventory System
Flexible inventory with weight limits, auto-stacking, and comprehensive serialization.

```gdscript
var inventory := PPInventory.new()
var health_potion := Pandora.get_entity(EntityIds.HEALTH_POTION) as PPItemEntity
inventory.add_item(health_potion, 5)
```

[Learn more →](core-systems/inventory.md)

## 🎮 Use Cases

Pandora+ is perfect for:

- ✅ **Action RPGs** - Real-time combat with stats and effects
- ✅ **Turn-Based RPGs** - Classic JRPG mechanics
- ✅ **Roguelikes** - Procedural items and effects
- ✅ **MMORPGs** - Multiplayer-ready serialization
- ✅ **Card Games** - Effect stacking and modifiers
- ✅ **Strategy Games** - Unit stats and abilities

## 🗺️ Roadmap

| Current v0.3.0-beta | Coming in v1.0.0-core | Planned for v1.0.0-premium|
|---------|--------|---------|
|✅ Runtime Stats System<br>✅ Inventory System<br>✅ Stats Modifier<br>✅ CombatCalculator|🔜 Equipment System<br>🔜 Quest System<br>🔜 Save/Load Framework|💎 Visual Quest Editor<br>💎 Advanced Combat System<br>💎 Skill Tree System<br>💎 More..|

## 🤝 Contributing

Pandora+ (Core) is open source and welcomes contributions!

- 🐛 [Report a bug](https://github.com/trobugno/pandora_plus/issues/new?template=bug_report.md)
- 💡 [Request a feature](https://github.com/trobugno/pandora_plus/issues/new?template=feature_request.md)
- 🔧 [Submit a pull request](https://github.com/trobugno/pandora_plus/pulls)

## 💬 Community & Support

- **GitHub Discussions**: Ask questions and share projects
- **GitHub Issues**: Report bugs and request features
- **Ko-fi**: Support development

## 📄 License

Pandora+ (Core) is licensed under the [MIT License](https://github.com/trobugno/pandora_plus/blob/main/LICENSE).

## 🙏 Credits

- **Pandora+** created by [Trobugno](https://github.com/trobugno)
- Built on top of [Pandora](https://bitbra.in/pandora) by [BitBrain](https://github.com/bitbrain)
- Powered by [Godot Engine](https://godotengine.org/)