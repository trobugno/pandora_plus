# Translation Editor

A built-in editor for localizing all string data stored in Pandora entities — item names, quest descriptions, NPC dialogues, and more. Translate directly inside Godot, export to standard formats, and apply translations with one click.

**Availability:** 💎 Premium (v1.3.0+)

---

## Overview

The Translation Editor eliminates the need to manage translation files manually. It scans all Pandora entities, discovers translatable strings automatically, and presents them in a spreadsheet-like grid where you can add locales and type translations inline.

When you're satisfied, click **Apply** to generate native Godot `.translation` files and register them in Project Settings. From that point, `tr()` works everywhere — no autoloads, no custom code.

### Key Features

- **Auto-Discovery** — scans all entities and finds every translatable string, including nested quest objectives and rewards
- **Spreadsheet Grid** — edit translations inline with color-coded status (translated, untranslated, stale)
- **Stale Detection** — when source text changes, affected translations are flagged for review
- **Apply to Godot** — generates `.translation` resources registered in Project Settings
- **CSV / PO Export & Import** — interoperate with external translation tools
- **Locale Management** — add and remove locales with full cleanup

---

## Getting Started

### Opening the Editor

1. Enable **Pandora+** in Project Settings > Plugins
2. Click the **Pandora+** tab in the main editor toolbar
3. Click **Translations** in the navigation bar

### First-Time Setup

On first activation, the editor automatically:

1. Loads (or creates) the translation store at `res://translations.pandora.json`
2. Scans all Pandora entities to discover translatable strings
3. Populates the entity tree and translation grid

### Adding a Locale

1. Click **+ Locale** in the toolbar
2. Enter an ISO 639-1 locale code (e.g., `it`, `fr`, `de`, `es`, `ja`)
3. A new column appears in the grid — start typing translations

### Applying Translations

1. Translate as many keys as you need
2. Click **Apply** in the toolbar
3. The editor generates one `.translation` file per locale (e.g., `pandora_plus.en.translation`, `pandora_plus.it.translation`)
4. Files are registered in Project Settings > Internationalization > Locale > Translations
5. `tr()` now returns translated text for any Pandora key

---

## User Interface

### Toolbar

| Control | Description |
|---------|-------------|
| **Sync** | Re-scan Pandora entities and update translation keys |
| **All / Untranslated / Stale** | Filter view by translation status |
| **Search** | Filter keys by alias, source text, or translation key |
| **+ Locale** | Add a new target locale |
| **Export** | Export to CSV (all locales) or PO/POT (per locale) |
| **Import** | Import from CSV or PO file |
| **Apply** | Generate `.translation` files and register in Project Settings |
| **Progress** | Shows translation count for the first target locale |

### Entity Tree (Left Panel)

A hierarchical tree mirroring your Pandora category structure. Each node shows the number of translatable strings.

- Click **All** to show every key
- Click a category (e.g., *Items*, *Quests*, *NPCs*) to filter the grid to that category and its subcategories
- Subcategories are nested (e.g., Items > Equipment)

### Translation Grid (Right Panel)

A spreadsheet layout with one row per translatable string.

| Column | Description |
|--------|-------------|
| **Key / Alias** | Human-readable path (e.g., `items.iron_sword._name`). Hover for the full translation key |
| **Source** | The original text in the source locale |
| **Locale columns** | One editable cell per target locale. Type to translate |

#### Color Coding

| Color | Meaning |
|-------|---------|
| Green | Translated and reviewed |
| Yellow | Translated, not yet reviewed |
| Red placeholder | Not translated |

Translations auto-save with a 500ms debounce after each edit.

#### Removing a Locale

Each locale column header has a trash icon button. Clicking it:
1. Checks if an applied `.translation` file exists for that locale
2. If yes, warns that the file will be removed from disk and Project Settings
3. On confirmation: removes the file, updates Project Settings, and deletes all translations for that locale

---

## Translation Keys

Every translatable string gets a unique key in the format:

```
pp.{entity_id}.{property_path}
```

For example: `pp.42.0._name` for entity 42's name.

Each key also has a human-readable **alias** built from the category path:

```
items.iron_sword._name
quests.rescue_princess.quest_data.description
npcs.blacksmith.quest_data.objectives.0.description
```

### What Gets Scanned

| Source | Property Path | Example |
|--------|--------------|---------|
| Entity name | `_name` | "Iron Sword" |
| String properties | `description`, `area_name`, etc. | "A sturdy blade" |
| Quest name | `quest_data.quest_name` | "Rescue the Princess" |
| Quest description | `quest_data.description` | "Find and rescue..." |
| Objective descriptions | `quest_data.objectives.0.description` | "Defeat 5 goblins" |
| Reward names | `quest_data.rewards.0.reward_name` | "Gold Reward" |
| Status effect descriptions | `status_effect.description` | "Increases attack by 10%" |
| String arrays | `dialogue_lines.0`, `.1`, etc. | "Hello, adventurer!" |

---

## Export & Import

### CSV

**Export** creates a single file with all locales:

```csv
key,alias,en,it,fr
pp.42.0._name,items.iron_sword._name,Iron Sword,Spada di Ferro,
pp.42.0.description,items.iron_sword.description,A sturdy blade,Una lama robusta,
```

**Import** auto-detects locale columns from the header. Keys not present in the store are skipped.

### PO / POT

**Export POT** (template) for use with tools like POEdit or Weblate:

```
#: pp.42.0._name
#. alias: items.iron_sword._name
msgctxt "pp.42.0._name"
msgid "Iron Sword"
msgstr ""
```

**Export PO** includes existing translations:

```
msgctxt "pp.42.0._name"
msgid "Iron Sword"
msgstr "Spada di Ferro"
```

**Import PO** matches entries by `msgctxt` (the translation key).

---

## Runtime Usage

After clicking **Apply**, translations are native Godot resources. Use them like any other Godot translation:

```gdscript
# Switch locale
TranslationServer.set_locale("it")

# Use tr() with the translation key
var translated_name = tr("pp.42.0._name")  # "Spada di Ferro"
```

### Convenience Helper

`I18nKeyGenerator` provides a static helper that generates the key and handles fallback automatically:

```gdscript
var entity: PandoraEntity = Pandora.get_entity("42.0")

# Returns translated text, or falls back to original if no translation exists
var name = I18nKeyGenerator.get_translated(entity, "_name")
var desc = I18nKeyGenerator.get_translated(entity, "description")
```

### How It Works

1. The Translation Editor stores all data in `res://translations.pandora.json`
2. Clicking **Apply** generates `.translation` resource files (one per locale)
3. These files are registered in Project Settings > Internationalization > Locale > Translations
4. Godot's `TranslationServer` loads them automatically at startup
5. `tr()` resolves keys to translated text based on the active locale

---

## Stale Detection

When source text changes (e.g., you rename an item from "Iron Sword" to "Steel Sword"), the editor detects the change via MD5 hashing and marks all existing translations for that key as **unreviewed**.

- The **Stale** filter in the toolbar shows only keys with changed source text
- Stale translations appear in yellow until reviewed
- Updating the translation text automatically clears the stale flag

---

## Settings

Three settings are available in Project Settings > Pandora+ > Config > i18n:

| Setting | Default | Description |
|---------|---------|-------------|
| `source_locale` | `en` | The language of your original entity text |
| `translation_file_path` | `res://translations.pandora.json` | Where the translation store is saved |
| `auto_sync_on_open` | `true` | Automatically scan entities when the tab is first opened |

---

## Tips & Best Practices

### Workflow

- **Sync first, translate second** — always Sync before a translation session to catch new or renamed entities
- **Apply after completing a batch** — you don't need to Apply after every single edit, just when you want translations active in-game
- **Use CSV for bulk translation** — export CSV, open in a spreadsheet, translate, import back
- **Use POT for professional translators** — POT/PO is the industry standard for localization tools

### Organization

- **Use the entity tree** to work category by category — translating all Items, then all Quests, etc.
- **Use the Untranslated filter** to find what's missing for a specific locale
- **Check Stale regularly** after editing entity data — it catches translations that need updating

### Performance

- The grid creates one row per translatable string. For very large projects (1000+ keys), use category filtering and search to keep the view manageable

---

## See Also

- [Quest System](../core-systems/quest-system.md) — Quest data model with translatable fields
- [NPC System](../core-systems/npc-system.md) — NPC entities with translatable names and descriptions
- [Equipment System](../core-systems/equipment-system.md) — Equipment with translatable names
- [Core vs Premium](../core-vs-premium.md) — Feature comparison

---

*Complete Guide for Pandora+ v1.4.0-premium*
