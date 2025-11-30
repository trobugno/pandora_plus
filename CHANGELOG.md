# 📜 Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## [0.2.0-alpha] - 2025-xx-xx
### What's new?
- Created **configuration.json** following the new **Custom Extensions Settings** introduced by me in Pandora addon.
- Renamed all property types adding the suffix **_property** to aligned them with new settings.
- Done a fixes to autoloads when the plugin is enabled.

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
### Planned for Premium version
- `RuntimeStats` and `StatsModifier` resources for advanced stat management.
- Level scaling and regeneration systems.
- Extended rarity and item tier support.
- More features
