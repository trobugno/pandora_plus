# 📜 Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## [1.1.1-core] (Current) - 2026-02-12

#### 🐛 Bug Fixes

- 🔧 Fixed update system ZIP extraction for distribution packages with `addons/pandora_plus/` structure

---
## [1.1.0-core] - 2026-02-11

#### ✨ New Features

**In-Editor Update System**
- ✨ Automatic update checking from GitHub Pages version manifest
- ✨ Update dialog with changelog display, progress bar, and version comparison
- ✨ One-click download and installation from GitHub Releases
- ✨ Automatic preservation of `configuration.json` during updates
- ✨ "Skip This Version" and "Remind Me Later" (24h) options
- ✨ Configurable auto-check interval via Project Settings (`pandora_plus/config/updates/`)

---
## [1.0.0-core] - 2026-02-03

#### 🎯 Major Features

**Quest System**
- ✨ Complete quest management system with entities, runtime tracking, and serialization
- ✨ Quest objectives with three core types: COLLECT, KILL, and TALK
- ✨ Quest rewards system with multiple reward types (items, currency, experience)
- ✨ Quest prerequisites and level requirements
- ✨ Auto-complete and hidden quest support
- ✨ Progress tracking with percentage calculation
- ✨ Quest status management (NOT_STARTED, ACTIVE, COMPLETED, FAILED, ABANDONED)
- ✨ Quest integration with NPC system for quest givers

**NPC System**
- ✨ NPC entity system with full runtime support
- ✨ Combat system with health tracking and stat modifiers
- ✨ Hostile/friendly NPC classification
- ✨ Quest giver capabilities with level-based quest filtering
- ✨ Dialogue and interaction support
- ✨ Location tracking
- ✨ Complete serialization/deserialization

**Equipment System**
- ✨ Equipment system with slot-based item management
- ✨ Equipped stats calculation and bonuses
- ✨ Equipment utilities for managing equipped items

**Save/Load System**
- ✨ Complete save/load system with slot management
- ✨ Player data serialization
- ✨ NPC state persistence
- ✨ Quest progress saving
- ✨ Inventory and equipment state preservation
- ✨ Multiple save slots support

**Player Management**
- ✨ Player data container with complete state tracking
- ✨ Player manager autoload for centralized operations
- ✨ Health and mana management
- ✨ Position and scene tracking
- ✨ Progress tracking (unlocked recipes, discovered locations, achievements)

**Utilities & Autoloads**
- ✨ PPQuestUtils autoload for quest management (start, complete, fail, abandon quests)
- ✨ PPNPCUtils autoload for NPC interactions and combat
- ✨ PPEquipmentUtils autoload for equipment management
- ✨ Reward delivery system with validation
- ✨ Comprehensive utility functions for all core systems

**UI Components**
- ✨ Quest property editor with visual interface
- ✨ Quest objective editor with type selection
- ✨ Quest reward editor with type selection
- ✨ Objectives window for managing quest objectives
- ✨ Rewards window for managing quest rewards

**Assets & Resources**
- ✨ 60+ custom icons for game elements (weapons, items, characters, effects, etc.)
- ✨ Quest entity category
- ✨ Quest objective entity
- ✨ Reward entity
- ✨ NPC entity
- ✨ Item entity

#### 🐛 Bug Fixes

**Critical Fixes**
- 🔧 Fixed inverted logic in `PPInventoryUtils.calculate_total_value()` and `calculate_total_weight()` that caused 100% crash rate
- 🔧 Fixed incorrect quantity calculation in `PPInventorySlot.merge_with()` that produced negative values
- 🔧 Fixed 34 array index out of bounds errors in save_data() methods across:
  - `PPItemDrop` (3 fixes)
  - `PPRecipe` (4 fixes)
  - `PPStats` (8 fixes)
  - `PPStatusEffect` (7 fixes)

**High Severity Fixes**
- 🔧 Fixed null slot access in `compact_inventory()`
- 🔧 Fixed null slot access in `can_craft()`

**Medium Severity Fixes**
- 🔧 Fixed uninitialized variables in `PPCombatCalculator` with sensible defaults
- 🔧 Added inventory space validation in `grant_reward()`
- 🔧 Added null checks in `inventory_data.has_item()`

**Other Fixes**
- 🔧 Minor bug fixing to improve performance

---

### [0.3.0-beta] - 2025-12-14

**Core Systems**
- ✅ Runtime Stats System
- ✅ Inventory System with weight and value tracking
- ✅ Recipe/Crafting System
- ✅ Stats Modifier System
- ✅ CombatCalculator
- ✅ GDUnit testing framework
- ✅ Documentation via GitHub Pages

---
## [0.2.0-alpha] - 2025-11-30
### What's new?
- Created **configuration.json** following the new **Custom Extensions Settings** introduced by me in Pandora addon.
- Renamed all property types adding the suffix **_property** to aligned them with new settings.
- Done a fixes to autoloads when the plugin is enabled.

### Notes
- This build uses an unapproved version of the Pandora addon. To view the PR I created, follow the [link](https://github.com/bitbrain/pandora/pull/230)

---
## [0.1.0-alpha] - 2025-11-10
### Added
- **Initial public release** of Pandora+.
- Integration with the Pandora ecosystem.
- Added core properties:
  - `PPStats`
  - `PPStatusEffect`
  - `PPItemDrop`
  - `PPIngredient`
  - `PPRecipe`
- Added autoload utilities:
  - `StatsUtils` (damage calculation)
  - `RecipeUtils` (crafting validation)
- Automatic registration of **Pandora categories**: `Rarity` and `Items`.
- Complete documentation in `README.md`.

### Notes
- This is the first public version (alpha) of Pandora+.
- Requires **Pandora** to be installed and enabled.
- Designed for **Godot 4.5+**.

---

## [Unreleased]
### Planned Features
- Additional quest objective types
- Enhanced NPC behaviors
- More utility functions
- Extended UI components
