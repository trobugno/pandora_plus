# Installation

Complete installation guide for **Pandora+** in your Godot project.

## 📋 System Requirements

| Requirement | Version | Status |
|-------------|---------|--------|
| **Godot Engine** | 4.5+ | Required |
| **Pandora** | 1.0-alpha9+ (by [Pull Request](https://github.com/bitbrain/pandora/pull/230)) | Required |
| **GDScript** | 2.0 | Required |
| **Operating System** | Windows / Linux / macOS | All supported |

---

## 🎯 Installation Method


#### Step 1: Download Pandora+

1. Go to [Pandora+ Releases](https://github.com/trobugno/pandora_plus/releases)
2. Download the latest version: `pandora_plus-v1.0.0-core.zip`
3. Extract the archive to a temporary location

#### Step 2: Install in Project

1. Copy the `pandora_plus` folder
2. Paste it into your project's `addons/` folder:
   ```
   your_project/
   ├── addons/
   │   ├── pandora/          ← Should already exist
   │   └── pandora_plus/     ← Paste here
   └── project.godot
   ```

#### Step 3: Enable Plugin

1. Open Godot Editor
2. Go to `Project → Project Settings → Plugins`
3. Find **Pandora+** in the list
4. Check ✅ **Enable**
5. Click **Reload** if prompted

---

## ✅ Verify Installation

After installation, verify everything is working:

### 1. Check Autoloads

Go to `Project → Project Settings → Autoload` and verify these are present:

**Core Utilities:**
- ✅ **PPCombatCalculator** - Combat calculations
- ✅ **PPInventoryUtils** - Inventory utilities
- ✅ **PPRecipeUtils** - Recipe/crafting utilities
- ✅ **PPQuestUtils** - Quest utilities
- ✅ **PPNPCUtils** - NPC utilities
- ✅ **PPEquipmentUtils** - Equipment utilities

**Core Managers:**
- ✅ **PPPlayerManager** - Player data management
- ✅ **PPQuestManager** - Quest tracking
- ✅ **PPNPCManager** - NPC management
- ✅ **PPTimeManager** - Time/day cycle management
- ✅ **PPSaveManager** - Save/load system

![Autoloads](../assets/screenshots/autoloads.png ':size=600')

### 2. Check Pandora Extensions Path

Go to `Project → Project Settings → Pandora → Extensions`:

- Verify `res://addons/pandora_plus/extensions` is in the list

### 3. Test with Script

Create a test script and run it:

```gdscript
extends Node

func _ready():
	print("=== Pandora+ Installation Test ===\n")

	# Test 1: Check core autoloads
	print("Core Utilities:")
	print("  PPCombatCalculator: ", PPCombatCalculator != null)
	print("  PPInventoryUtils: ", PPInventoryUtils != null)
	print("  PPRecipeUtils: ", PPRecipeUtils != null)
	print("  PPQuestUtils: ", PPQuestUtils != null)
	print("  PPNPCUtils: ", PPNPCUtils != null)

	# Test 2: Check managers
	print("\nCore Managers:")
	print("  PPPlayerManager: ", PPPlayerManager != null)
	print("  PPQuestManager: ", PPQuestManager != null)
	print("  PPSaveManager: ", PPSaveManager != null)

	# Test 3: Create runtime stats
	var stats = PPRuntimeStats.new({"health": 100, "attack": 15})
	print("\nRuntime stats created: HP=", stats.get_effective_stat("health"))

	# Test 4: Create inventory
	var inv = PPInventory.new(20)
	print("Inventory created with 20 slots")

	# Test 5: Create player data
	var player_data = PPPlayerData.new()
	print("Player data created: ", player_data.player_name)

	print("\n✅ All tests passed! Pandora+ is ready to use.")
```

Expected output:
```
=== Pandora+ Installation Test ===

Core Utilities:
  PPCombatCalculator: true
  PPInventoryUtils: true
  PPRecipeUtils: true
  PPQuestUtils: true
  PPNPCUtils: true

Core Managers:
  PPPlayerManager: true
  PPQuestManager: true
  PPSaveManager: true

Runtime stats created: HP=100
Inventory created with 20 slots
Player data created: Hero

✅ All tests passed! Pandora+ is ready to use.
```

---

## 🔧 Install Pandora (Prerequisite)

> If you already have Pandora installed, skip this section.

### Why Pandora is Required

Pandora+ extends Pandora's data management system. Without Pandora, Pandora+ cannot function.

### Installing Pandora

1. **Download Pandora**
   - Go to [Pandora Releases](https://github.com/bitbrain/pandora/releases)
   - Download version **1.0-alpha9 or higher**<br>
     ⚠️​ **Note**: If this [Pull Request](https://github.com/bitbrain/pandora/pull/230) is not merged yet, please download Pandora using it.

2. **Install in Project**
   ```
   your_project/
   ├── addons/
   │   └── pandora/     ← Install here
   └── project.godot
   ```

3. **Enable Plugin**
   - `Project → Project Settings → Plugins`
   - Enable **Pandora**
   - Restart Godot

> 📖 For detailed Pandora documentation, visit [bitbra.in/pandora](https://bitbra.in/pandora)

---

## 🎨 Optional: Configure Pandora+

Customize Pandora+ behavior in `Project Settings → Pandora+ → Config`:

### Combat Calculator Settings

Control damage calculation formulas and combat mechanics.

| Setting | Description | Default | Range |
|---------|-------------|---------|-------|
| `Defense Reduction Factor` | Each point in Defense reduces damage by this factor | `0.5` | - |
| `Armor Diminishing Returns` | Point where armor has 50% effectiveness | `100.0` | - |
| `Crit Rate Cap` | Maximum critical hit rate percentage | `100.0` | - |
| `Crit Damage Base` | Base critical damage multiplier (150% = 1.5x) | `150.0` | - |

---

### Save System Settings

Configure the save/load system behavior.

| Setting | Description | Default | Range |
|---------|-------------|---------|-------|
| `Max Save Slots` | Maximum number of save slots available | `3` | 1-20 |
| `Autosave Enabled` | Enable automatic saving | `true` | - |
| `Autosave Interval (seconds)` | Time between autosaves | `300.0` (5 min) | 30-3600 |
| `Save Directory` | Path where save files are stored | `user://saves/` | - |
| `Save File Extension` | Extension for save files | `.json` | - |

---

### Player Settings

Configure default player starting values.

| Setting | Description | Default | Range |
|---------|-------------|---------|-------|
| `Starting Currency` | Player's starting gold/currency | `0` | 0-999999 |
| `Max Inventory Slots` | Maximum inventory slots (-1 = unlimited) | `-1` | -1-999 |
| `Respawn Health Percentage` | Health % on respawn (1.0 = 100%) | `1.0` | 0.0-1.0 |
| 💎 `Skill Points Per Level` | Skill points gained per level (Premium only) | `1` | 1-10 |

---

### Time System Settings

Configure day/night cycle and time management.

| Setting | Description | Default | Range |
|---------|-------------|---------|-------|
| `Starting Day` | Game starts at this day number | `1` | 1-999 |
| `Starting Hour` | Game starts at this hour (24h format) | `12` | 0-23 |
| `Time Scale Default` | Default time flow speed (1.0 = normal) | `1.0` | 0.0-10.0 |

---

### Example Configuration

```gdscript
# Access settings in code
var defense_factor = ProjectSettings.get_setting("pandora_plus/config/combat_calculator/defense_reduction_factor")
var max_saves = ProjectSettings.get_setting("pandora_plus/config/save_system/max_save_slots")
var starting_gold = ProjectSettings.get_setting("pandora_plus/config/player/starting_currency")
```

---

## 🐛 Troubleshooting

### Issue: Plugin doesn't appear in list

**Cause:** Plugin folder not in correct location

**Solution:**
1. Verify folder structure:
   ```
   addons/
   └── pandora_plus/
       ├── plugin.cfg        ← Must exist
       ├── plugin.gd
       └── ... other files
   ```
2. Check `plugin.cfg` exists and has correct content
3. Restart Godot Editor

---

### Issue: "Pandora not found" error

**Cause:** Pandora is not installed or not enabled

**Solution:**
1. Install Pandora (see [Install Pandora section](#install-pandora-prerequisite))
2. Verify Pandora is **enabled** in Plugins
3. Restart Godot

---

### Issue: Autoloads not registered

**Cause:** Plugin initialization failed

**Solution:**
1. Disable Pandora+ plugin
2. Close Godot
3. Delete `.godot/` folder in your project (cache)
4. Reopen Godot
5. Enable Pandora+ again
6. Check Output for errors

---

## 🗑️ Uninstalling Pandora+

If you need to remove Pandora+:

1. Disable plugin in `Project → Project Settings → Plugins`
2. Close Godot
3. Delete `addons/pandora_plus/` folder
4. Delete `.godot/` folder (cache)
5. Reopen Godot

> ⚠️ **Warning:** This will break any code using Pandora+ classes. Make sure to remove all references first.

---

## 🎉 Next Steps

**Installation complete!** Now you're ready to:

1. 📖 Follow the [Getting Started Guide](getting-started/setup.md)
2. 🎓 Learn about [Runtime Stats](core-systems/runtime-stats.md)
3. 🎒 Explore the [Inventory System](core-systems/inventory.md)
4. 🔨 Try the [Recipe System](core-systems/recipe.md)

---

## 🤝 Need Help?

- 🐛 [Report Installation Issues](https://github.com/trobugno/pandora_plus/issues/new?labels=installation,bug)
- 💬 [Ask in Discussions](https://github.com/trobugno/pandora_plus/discussions)