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
2. Download the latest version: `pandora_plus-v0.3.0-beta.zip`
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

- ✅ **CombatCalculator** - `res://addons/pandora_plus/autoload/combat_calculator.gd`
- ✅ **PPInventoryUtils** - `res://addons/pandora_plus/autoload/pp_inventory_utils.gd`
- ✅ **PPRecipeUtils** - `res://addons/pandora_plus/autoload/pp_recipe_utils.gd`
- ✅ **PPStatsUtils** - `res://addons/pandora_plus/autoload/pp_stats_utils.gd`

![Autoloads](../assets/screenshots/autoloads.png ':size=600')

### 2. Check Pandora Extensions Path

Go to `Project → Project Settings → Pandora → Extensions`:

- Verify `res://addons/pandora_plus/extensions` is in the list

### 3. Test with Script

Create a test script and run it:

```gdscript
extends Node

func _ready():
	# Test 1: Check autoloads
	print("CombatCalculator loaded: ", CombatCalculator != null)
	print("PPInventoryUtils loaded: ", PPInventoryUtils != null)
	print("PPRecipeUtils loaded: ", PPRecipeUtils != null)
	
	# Test 2: Create runtime stats
	var stats = PPRuntimeStats.new({"health": 100, "attack": 15})
	print("Runtime stats created: ", stats.get_effective_stat("health"))
	
	# Test 3: Create inventory
	var inv = PPInventory.new(20)
	print("Inventory created with %d slots" % inv.max_slots)
	
	print("\n✅ All tests passed! Pandora+ is ready to use.")
```

Expected output:
```
CombatCalculator loaded: true
PPInventoryUtils loaded: true
PPRecipeUtils loaded: true
Runtime stats created: 100
Inventory created with 20 slots

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

Customize Pandora+ behavior in `Project Settings → Pandora+`:

### Available Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `Defense Reducution Factor` | Each point in **Defense** reduces damage by | `0.5` |
| `Armor Diminishing Returns` | Point where armor has 50% effectiveness | `100` |
| `Crit Rate Cap` | Crit Rate Percentage Cap | `100` |
| `Crit Damage Base` | Base Crit Damage (150% = 1.5x) | `150` |

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

## 🔄 Updating Pandora+ from v0.2.0-alpha

Check [Migration Guide](getting-started/migration-from-v0.2.0-alpha.md) for breaking changes

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