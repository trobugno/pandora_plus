## 🧩 Pandora+ — Advanced RPG Addon for Godot
> Expand BitBrain’s **Pandora** with ready-to-use, RPG-oriented data properties for your Godot projects.

### ⚙️ Overview
**Pandora+** is an official extension pack for [Pandora](https://bitbra.in/pandora/#/), adding a collection of custom data properties designed for **RPGs, adventure games, and narrative-driven projects**.

Built on top of the new _custom extension system_ (introduced via my [Pull Request to Pandora](https://github.com/bitbrain/pandora/pull/229)
), Pandora+ enables developers to integrate complex gameplay data — such as stats, inventory, quests, and dialogue — directly into Pandora’s data layer.

### 💡 Why Pandora+?
While Pandora provides a powerful and lightweight foundation for data serialization and synchronization, many developers working on game systems (RPGs in particular) need additional property types that handle domain-specific logic.

**Pandora+** solves this by providing a plug-and-play collection of specialized properties and helper scripts — ready to use, extend, or adapt.

## 🔌 Pandora Integration
Pandora+ integrates seamlessly with [Pandora by BitBrain](https://github.com/bitbrain/pandora).

When enabled, the addon automatically registers its custom extensions by adding the following path to Pandora’s settings: `res://addons/pandora_plus/extensions`
This means that all new properties (e.g., `ItemDropProperty`, `StatusEffectProperty`) become immediately available in the Pandora Editor without manual setup.

### 🧱 Core Features (v1.0)
|Property              |Description                                                                                     |
|----------------------|------------------------------------------------------------------------------------------------|
|`PPStats`             |Defines the main attributes of an entity (mob, player, NPC, etc.).                              |
|`PPIngredient`        |Defines a single ingredient entry, used by recipes and item crafting.                           |
|`PPRecipe`            |Represents a full recipe composed of multiple ingredients.                                      |
|`PPItemDrop`          |Defines a potential loot drop for an entity.                                                    |
|`PPStatusEffect`      |Describes temporary effects that can alter entity states (e.g. poison, burn, bleed).            |

Each property is fully compatible with Pandora’s serialization system and supports the same update and sync mechanisms.

### 📦 Requirements & Compatibility
|Requirement  |	Version                                               |
|-------------|-------------------------------------------------------|
|Godot Engine |	4.5+                                                  |
|Pandora	  | 1.0-alpha9+ (requires the custom extension system PR) |

> If you’re using a version of Pandora prior to 1.0-alpha9+, make sure to update to access the custom extension API.

Pandora+ has been tested with both standalone and integrated Pandora setups (autoload or per-scene usage).

### 🚀 Installation
1. Download the `pandora_plus/` folder and copy it into your project’s `addons/` directory.
1. Enable it from **Project → Project Settings → Plugins**.
1. Pandora+ will automatically register all custom property types.
1. You can now use them in your scripts, for example:
```gdscript
@export var stats: PPStats
```

### ⚙️ Utilities

Pandora+ provides two autoloaded singletons to simplify logic integration:
- `StatsUtils` – methods for calculating physical and magical damage.
- `RecipeUtils` – methods for verifying crafting eligibility.
You can directly access them anywhere in your project:
```gdscript
var can_craft = RecipeUtils.can_craft(player_inventory, recipe)
var damage = StatsUtils.calculate_damage(attacker_stats, target_stats)
```

### 🗂️ Categories Added
When Pandora+ is enabled, two new categories are registered automatically:
- `Rarity` – defines item rarity tiers.
- `Items` – manages base item entities compatible with `PPItemDrop`, `PPIngredient` and `PPRecipe`.

### 💡 Future Additions (Premium version)
- RuntimeStats system with scaling and modifiers 
- Advanced Status Effects with types, origins, etc.
- Other features

### 🧑‍💻 Credits
Created by **Trobugno**, contributor to _Pandora_ and developer of the upcoming fantasy RPG _Arkaruh’s Tale_.

Pandora+ is an independent extension, fully compatible with Pandora by BitBrain.
Special thanks to **BitBrain** for developing such a robust foundation.

### ☕ Support the Project

If you find Pandora+ useful, consider supporting development or unlocking future packs via Ko-fi:
👉 [ko-fi.com/trobugno](https://ko-fi.com/trobugno)

Your support helps maintain both _Arkaruh’s Tale_ and future open-source tools for the Godot community.
