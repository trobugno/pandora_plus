# Pandora+ Documentation

Welcome to the **Pandora+** documentation! This comprehensive guide will help you build production-ready RPG systems for Godot Engine.

## 🎯 What is Pandora+?

Pandora+ extends [Pandora by BitBrain](https://github.com/bitbrain/pandora) with specialized RPG-oriented data properties and runtime systems. It provides everything you need to create complex RPG mechanics without reinventing the wheel.

**Pandora+ comes in two editions:**
- **Core (Free & Open Source)** - *v1.2.5-core* : 
  - Basic **Quest System** (Talk, Collect, Kill) + Rewards (Item, Experience, Currency) ![new](assets/new.png)
  - Basic **NPC System** (Strongly related to Quests) ![new](assets/new.png)
  - **Player Data & Manager** ![new](assets/new.png)
  - **Save/Load Framework** ![new](assets/new.png)
  - **Inventory System** 
  - **Stats & Modifiers System**
  - **Crafting/Recipe System**
  - **Item Drop System**
- **💎 Premium** - *v1.0.2-premium* : 
  - <u>All Core features</u>
  - NPC extended with **Merchant/Trading System** ![new](assets/new.png)
  - NPC extended with **Scheduled/Routine System** ![new](assets/new.png)
  - **Equipment System** with bonuses, etc ![new](assets/new.png)
  - Player extended with **Leveling & Progression** ![new](assets/new.png)

[See full comparison →](core-vs-premium.md)

---

## ✨ Core Features (Free)

### 📜 Quest System
Complete quest management with objectives, rewards, and state tracking. Build complex quest chains with prerequisites.

```gdscript
# Start a quest
var quest_entity = Pandora.get_entity("QUEST_VILLAGE_HELP") as PPQuestEntity
var runtime_quest = PPQuestManager.start_quest(quest_entity)

# Track progress
PPQuestUtils.track_item_collected(runtime_quest, item, 5)
PPQuestUtils.track_enemy_killed(runtime_quest, "goblin")
```

[Learn more →](core-systems/quest-system.md)

### 👥 NPC System
Dynamic NPC management with dialogue, quest giving, and runtime state. NPCs can give quests, track health, and interact with the world.

```gdscript
# Spawn NPC
var npc_entity = Pandora.get_entity("NPC_VILLAGE_ELDER") as PPNPCEntity
var runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

# Get available quests from NPC
var quests = runtime_npc.get_available_quests(completed_quest_ids)
```

[Learn more →](core-systems/npc-system.md)

### 💾 Player Data
Centralized player state management with save/load support.

```gdscript
# Access player data
var player_data = PPPlayerData.new()
player_data.set_player_name("Hero")

# Automatically integrated with quest and NPC systems
```

[Learn more →](core-systems/player-data.md)

### 📊 Runtime Stats System
Dynamic stat calculation with support for temporary and permanent modifiers. Perfect for buffs, debuffs, equipment bonuses, and level-up systems.

```gdscript
var runtime_stats := PPRuntimeStats.new(base_stats)
var buff := PPStatModifier.create_percent("attack", 50.0, "potion", 60.0)
runtime_stats.add_modifier(buff)
```

[Learn more →](core-systems/runtime-stats.md)

### 🎒 Inventory System
Flexible inventory with weight limits, auto-stacking, and comprehensive serialization.

```gdscript
var inventory := PPInventory.new()
var health_potion := Pandora.get_entity(EntityIds.HEALTH_POTION) as PPItemEntity
inventory.add_item(health_potion, 5)
```

[Learn more →](core-systems/inventory-system.md)

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

[Learn more →](properties/recipe.md)

---

## 🎮 Use Cases

Pandora+ is perfect for:

- ✅ **Action RPGs** - Real-time combat with stats and effects
- ✅ **Turn-Based RPGs** - Classic JRPG mechanics
- ✅ **Roguelikes** - Procedural items and effects
- ✅ **MMORPGs** - Multiplayer-ready serialization
- ✅ **Card Games** - Effect stacking and modifiers
- ✅ **Strategy Games** - Unit stats and abilities

## 🗺️ Roadmap

| Version | Core (Free) | Premium | Status |
|---------|-------------|---------|--------|
|**v0.3.0-beta**|✅ Runtime Stats System<br>✅ Inventory System<br>✅ Recipe/Crafting<br>✅ Combat Calculator<br>✅ Status Effects<br>✅ Item System with Rarity|N/A|Released (14 Dec 2025)|
|**v1.0.0**|✅ All previous features<br>✅ Quest System<br>✅ NPC System<br>✅ Player Data<br>✅ Quest Objectives & Rewards<br>✅ Save/Load Framework|💎 All Core features<br>💎 Merchant/Trading System<br>💎 NPC Scheduled/Routine<br>💎 Save/Load Framework<br>💎 Equipment System<br>💎 Leveling & Progression|Released (Feb 2026)|
|**Future**|N/A|💎 Advanced Status Effect<br>💎 Visual Quest Editor<br>💎 Skill Tree System<br>💎 Advanced Combat System<br>💎 Procedural Quest Generation|Planned|

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