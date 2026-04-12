# 💎 PPEquipmentUtils

**Extends:** `Node`

Utility singleton for managing equipment operations including equipping, unequipping, and stat modifier application.

---

## Description

`PPEquipmentUtils` is an autoloaded singleton that handles all equipment-related operations. It manages the process of equipping and unequipping items, automatically applying and removing stat modifiers to character stats.

The utility integrates seamlessly with:
- **PPInventory** - Manages equipment slots
- **PPEquipmentEntity** - Equipment items
- **PPRuntimeStats** - Character stats with modifiers

---

## Setup

Add to autoload in Project Settings:

```gdscript
# Project -> Project Settings -> Autoload
# Name: EquipmentUtils
# Path: res://addons/pandora_plus/autoloads/PPEquipmentUtils.gd
```

**Access globally:**
```gdscript
PPEquipmentUtils.equip_item(inventory, sword, character_stats)
```

---

## Signals

### equipment_equipped

```gdscript
signal equipment_equipped(character_stats: PPRuntimeStats, slot_name: String, item: PPEquipmentEntity)
```

Emitted when equipment is successfully equipped.

**Parameters:**
- `character_stats`: Character's runtime stats
- `slot_name`: Slot where item was equipped (e.g., "WEAPON")
- `item`: Equipment that was equipped

**Example:**
```gdscript
PPEquipmentUtils.equipment_equipped.connect(_on_equipment_equipped)

func _on_equipment_equipped(stats: PPRuntimeStats, slot: String, item: PPEquipmentEntity):
    print("Equipped %s in %s slot" % [item.get_item_name(), slot])

    # Update character appearance
    update_character_mesh(slot, item)

    # Play equip sound
    audio_player.play_equip_sound(item.get_equipment_slot())

    # Show notification
    show_notification("Equipped: %s" % item.get_item_name())
```

---

### equipment_unequipped

```gdscript
signal equipment_unequipped(character_stats: PPRuntimeStats, slot_name: String, item: PPEquipmentEntity)
```

Emitted when equipment is successfully unequipped.

**Parameters:**
- `character_stats`: Character's runtime stats
- `slot_name`: Slot from which item was removed
- `item`: Equipment that was unequipped

**Example:**
```gdscript
PPEquipmentUtils.equipment_unequipped.connect(_on_equipment_unequipped)

func _on_equipment_unequipped(stats: PPRuntimeStats, slot: String, item: PPEquipmentEntity):
    print("Unequipped %s from %s" % [item.get_item_name(), slot])

    # Remove visual equipment
    clear_character_mesh(slot)

    # Update UI
    refresh_equipment_ui()
```

---

### set_bonus_activated

```gdscript
signal set_bonus_activated(set_entity: PPEquipmentSetEntity, tier: int, bonuses: Dictionary)
```

Emitted when a set bonus tier activates.

**Parameters:**
- `set_entity`: The equipment set entity
- `tier`: Number of pieces required for this tier
- `bonuses`: Dictionary of stat_name -> bonus_value

**Example:**
```gdscript
PPEquipmentUtils.set_bonus_activated.connect(func(set_entity, tier, bonuses):
    print("Set '%s' tier %d activated!" % [set_entity.get_set_name(), tier])
    for stat in bonuses:
        print("  +%d %s" % [bonuses[stat], stat])
)
```

---

### set_bonus_deactivated

```gdscript
signal set_bonus_deactivated(set_entity: PPEquipmentSetEntity)
```

Emitted when all set bonus tiers for a set are deactivated (not enough pieces equipped).

---

### set_bonus_changed

```gdscript
signal set_bonus_changed(set_entity: PPEquipmentSetEntity, old_tier: int, new_tier: int)
```

Emitted whenever a set bonus tier changes (up or down), including activation (old_tier=0) and deactivation (new_tier=0).

**Example:**
```gdscript
PPEquipmentUtils.set_bonus_changed.connect(func(set_entity, old_tier, new_tier):
    if new_tier > old_tier:
        show_notification("Set bonus upgraded! %s: %d pieces" % [set_entity.get_set_name(), new_tier])
    else:
        show_notification("Set bonus downgraded: %s" % set_entity.get_set_name())
)
```

---

## Methods

### can_equip()

Checks if an item can be equipped.

```gdscript
func can_equip(item: PandoraEntity) -> bool
```

**Parameters:**
- `item`: Item to check

**Returns:** `true` if item is PPEquipmentEntity, `false` otherwise

**Example:**
```gdscript
var item = Pandora.get_entity("IRON_SWORD")

if PPEquipmentUtils.can_equip(item):
    print("This item can be equipped")
    var equipment = item as PPEquipmentEntity
    print("Slot: ", equipment.get_equipment_slot())
else:
    print("This is not equipment")
```

**Use Cases:**
- UI validation (show equip button only for equipment)
- Drag-and-drop validation
- Inventory filtering

---

### get_equipment_slot()

Gets the equipment slot name for an equipment item.

```gdscript
func get_equipment_slot(item: PPEquipmentEntity) -> String
```

**Parameters:**
- `item`: Equipment item

**Returns:** Slot name (e.g., "HEAD", "WEAPON") or empty string if null

**Example:**
```gdscript
var helmet = Pandora.get_entity("IRON_HELMET") as PPEquipmentEntity
var slot = PPEquipmentUtils.get_equipment_slot(helmet)

print("Equip to slot: ", slot)  # "HEAD"
```

---

### get_equipment_stats()

Gets the stat bonuses from an equipment item.

```gdscript
func get_equipment_stats(item: PPEquipmentEntity) -> PPStats
```

**Parameters:**
- `item`: Equipment item

**Returns:** PPStats or null if item has no stats

**Example:**
```gdscript
var armor = Pandora.get_entity("STEEL_ARMOR") as PPEquipmentEntity
var stats = PPEquipmentUtils.get_equipment_stats(armor)

if stats:
    print("Health: +%d" % stats._health)
    print("Defense: +%d" % stats._defense)
```

---

### equip_item()

Equips an item from inventory to equipment slot.

```gdscript
func equip_item(
    inventory: PPInventory,
    item: PPEquipmentEntity,
    character_stats: PPRuntimeStats
) -> bool
```

**Parameters:**
- `inventory`: Player's inventory
- `item`: Equipment to equip
- `character_stats`: Character's runtime stats

**Returns:** `true` if successful, `false` otherwise

**Behavior:**
1. Validates item is PPEquipmentEntity
2. Checks item exists in inventory
3. Unequips current item in slot (if any)
4. Removes item from inventory
5. Adds item to equipment slot
6. Applies stat modifiers to character_stats
7. Emits `equipment_equipped` signal
8. Emits inventory `item_equipped` signal

**Example:**
```gdscript
var sword = Pandora.get_entity("IRON_SWORD") as PPEquipmentEntity

if PPEquipmentUtils.equip_item(player.inventory, sword, player.runtime_stats):
    print("Equipped successfully!")
    print("New attack: ", player.runtime_stats.get_effective_stat("attack"))
else:
    print("Failed to equip")
    # Reasons:
    # - Item not in inventory
    # - Item is not PPEquipmentEntity
    # - Inventory error
```

**Error Messages:**
```gdscript
# Not equipment
"Item 'Health Potion' is not equippable (not PPEquipmentEntity)"

# Not in inventory
"Item 'Iron Sword' not found in inventory"
```

---

### unequip_item()

Unequips an item from equipment slot.

```gdscript
func unequip_item(
    inventory: PPInventory,
    slot_name: String,
    character_stats: PPRuntimeStats
) -> bool
```

**Parameters:**
- `inventory`: Player's inventory
- `slot_name`: Slot to unequip (e.g., "WEAPON", "HEAD")
- `character_stats`: Character's runtime stats

**Returns:** `true` if successful, `false` otherwise

**Behavior:**
1. Validates slot has equipment
2. Removes stat modifiers from character_stats
3. Removes item from equipment slot
4. Returns item to inventory
5. Emits `equipment_unequipped` signal
6. Emits inventory `item_unequipped` signal

**Example:**
```gdscript
# Unequip weapon
if PPEquipmentUtils.unequip_item(player.inventory, "WEAPON", player.runtime_stats):
    print("Weapon unequipped")
else:
    print("No weapon equipped")

# Unequip all accessories
PPEquipmentUtils.unequip_item(player.inventory, "ACCESSORY_1", player.runtime_stats)
PPEquipmentUtils.unequip_item(player.inventory, "ACCESSORY_2", player.runtime_stats)
```

**Error Messages:**
```gdscript
# Empty slot
"No equipment in slot 'WEAPON'"
```

---

### unequip_all()

Unequips all equipped items.

```gdscript
func unequip_all(inventory: PPInventory, character_stats: PPRuntimeStats) -> int
```

**Parameters:**
- `inventory`: Player's inventory
- `character_stats`: Character's runtime stats

**Returns:** Number of items unequipped

**Example:**
```gdscript
# Remove all equipment
var count = PPEquipmentUtils.unequip_all(player.inventory, player.runtime_stats)
print("Removed %d equipment pieces" % count)

# Use cases:
# - Death penalty
# - Equipment durability system (all broken)
# - Transformation/shapeshift (can't wear equipment)
# - Entering water (remove heavy armor)
```

**Advanced Example:**
```gdscript
func apply_death_penalty():
    # Unequip everything
    var unequipped = PPEquipmentUtils.unequip_all(player.inventory, player.runtime_stats)

    # Damage all unequipped items
    for slot in player.inventory.equipped_items.keys():
        var item_slot = player.inventory.all_items.find(func(s):
            return s and s.item in [unequipped_items]
        )
        if item_slot:
            damage_item(item_slot.item, 10)  # 10% durability loss

    print("Death penalty: %d items unequipped and damaged" % unequipped)
```

---

### get_total_equipment_stats()

Gets total stat bonuses from all equipped items.

```gdscript
func get_total_equipment_stats(inventory: PPInventory) -> Dictionary
```

**Parameters:**
- `inventory`: Player's inventory

**Returns:** Dictionary with stat_name -> total_bonus

**Example:**
```gdscript
var totals = PPEquipmentUtils.get_total_equipment_stats(player.inventory)

print("Total equipment bonuses:")
for stat_name in totals:
    print("  %s: +%d" % [stat_name, totals[stat_name]])

# Example output:
#   health: +150
#   attack: +45
#   defense: +30
#   crit_rate: +15.0

# Use for character sheet display
func update_stats_ui():
    var equipment_bonuses = PPEquipmentUtils.get_total_equipment_stats(player.inventory)

    health_label.text = "HP: %d (+%d)" % [
        player.runtime_stats.get_effective_stat("health"),
        equipment_bonuses.get("health", 0)
    ]

    attack_label.text = "ATK: %d (+%d)" % [
        player.runtime_stats.get_effective_stat("attack"),
        equipment_bonuses.get("attack", 0)
    ]
```

---

## Usage Examples

### Example 1: Equipment Quick-Swap

```gdscript
func quick_swap_weapon(new_weapon: PPEquipmentEntity):
    # Automatically handles unequipping old weapon
    if PPEquipmentUtils.equip_item(player.inventory, new_weapon, player.runtime_stats):
        print("Swapped to: ", new_weapon.get_item_name())

        # Get stat changes
        var equipment_bonuses = PPEquipmentUtils.get_total_equipment_stats(player.inventory)
        var attack = equipment_bonuses.get("attack", 0)
        print("Total weapon attack: +%d" % attack)
```

---

### Example 2: Equipment Validation Before Equip

```gdscript
func try_equip_with_validation(item: PPEquipmentEntity) -> bool:
    # Check if can equip
    if not PPEquipmentUtils.can_equip(item):
        show_error("This item cannot be equipped")
        return false

    # Check if in inventory
    if not player.inventory.has_item(item):
        show_error("Item not in inventory")
        return false

    # Check level requirement (custom validation)
    var level_req = item.get_int("level_requirement")
    if level_req > 0 and player.level < level_req:
        show_error("Requires level %d" % level_req)
        return false

    # Check class requirement
    var class_req = item.get_string("class_requirement")
    if not class_req.is_empty() and class_req != player.character_class:
        show_error("Requires %s class" % class_req)
        return false

    # Equip
    if PPEquipmentUtils.equip_item(player.inventory, item, player.runtime_stats):
        show_notification("Equipped: %s" % item.get_item_name())
        return true

    return false
```

---

### Example 3: Equipment Comparison Tooltip

```gdscript
class_name EquipmentTooltip
extends PanelContainer

func show_for_item(new_item: PPEquipmentEntity):
    var slot = new_item.get_equipment_slot()

    # Get currently equipped item
    var current_item: PPEquipmentEntity = null
    if player.inventory.has_equipment_in_slot(slot):
        var equipped = player.inventory.get_equipped_item(slot)
        current_item = equipped.item as PPEquipmentEntity

    # Show item info
    name_label.text = new_item.get_item_name()
    slot_label.text = "Slot: %s" % slot

    # Compare stats
    var new_stats = PPEquipmentUtils.get_equipment_stats(new_item)
    var current_stats = PPEquipmentUtils.get_equipment_stats(current_item) if current_item else null

    comparison_panel.clear()

    if new_stats:
        show_stat_comparison("Health", current_stats, new_stats, "_health")
        show_stat_comparison("Attack", current_stats, new_stats, "_attack")
        show_stat_comparison("Defense", current_stats, new_stats, "_defense")

func show_stat_comparison(label: String, current: PPStats, new: PPStats, stat_field: String):
    var current_val = current.get(stat_field) if current else 0
    var new_val = new.get(stat_field) if new else 0
    var diff = new_val - current_val

    if new_val > 0 or current_val > 0:
        var comparison_label = Label.new()

        if diff > 0:
            comparison_label.text = "%s: %d → %d (+%d)" % [label, current_val, new_val, diff]
            comparison_label.modulate = Color.GREEN
        elif diff < 0:
            comparison_label.text = "%s: %d → %d (%d)" % [label, current_val, new_val, diff]
            comparison_label.modulate = Color.RED
        else:
            comparison_label.text = "%s: %d" % [label, new_val]

        comparison_panel.add_child(comparison_label)
```

---

### Example 4: Auto-Equip Best Item

```gdscript
func auto_equip_best_weapon():
    var all_weapons = get_all_weapons_in_inventory()

    if all_weapons.is_empty():
        print("No weapons in inventory")
        return

    # Find weapon with highest attack
    var best_weapon: PPEquipmentEntity = null
    var best_attack = 0

    for weapon in all_weapons:
        var stats = PPEquipmentUtils.get_equipment_stats(weapon)
        if stats and stats._attack > best_attack:
            best_attack = stats._attack
            best_weapon = weapon

    if best_weapon:
        PPEquipmentUtils.equip_item(player.inventory, best_weapon, player.runtime_stats)
        print("Auto-equipped: %s (ATK: +%d)" % [best_weapon.get_item_name(), best_attack])

func get_all_weapons_in_inventory() -> Array[PPEquipmentEntity]:
    var weapons: Array[PPEquipmentEntity] = []

    for slot in player.inventory.all_items:
        if not slot or not slot.item:
            continue

        if PPEquipmentUtils.can_equip(slot.item):
            var equipment = slot.item as PPEquipmentEntity
            if equipment.get_equipment_slot() == "WEAPON":
                weapons.append(equipment)

    return weapons
```

---

### Example 5: Equipment Set Bonus UI

```gdscript
# Set bonuses are managed automatically — just connect to signals for UI
func _ready():
    PPEquipmentUtils.set_bonus_activated.connect(_on_set_bonus_activated)
    PPEquipmentUtils.set_bonus_deactivated.connect(_on_set_bonus_deactivated)
    PPEquipmentUtils.set_bonus_changed.connect(_on_set_bonus_changed)

func _on_set_bonus_activated(set_entity: PPEquipmentSetEntity, tier: int, bonuses: Dictionary):
    show_set_bonus_popup(set_entity.get_set_name(), tier, bonuses)

func _on_set_bonus_deactivated(set_entity: PPEquipmentSetEntity):
    hide_set_bonus_indicator(set_entity.get_entity_id())

func _on_set_bonus_changed(set_entity: PPEquipmentSetEntity, old_tier: int, new_tier: int):
    update_set_bonus_indicator(set_entity.get_entity_id(), new_tier)

func display_all_set_statuses():
    var all_sets = PPEquipmentUtils.get_all_equipment_sets()
    for set_entity in all_sets:
        var status = PPEquipmentUtils.get_set_status(set_entity, player.inventory)
        print("%s: %d/%d pieces (tier %d)" % [
            set_entity.get_set_name(),
            status.equipped_count,
            status.total_pieces,
            status.active_tier
        ])
        if status.next_tier > 0:
            print("  Next tier at %d pieces" % status.next_tier)
```

---

## Set Bonus Methods

Set bonuses are automatically managed when equipment is equipped/unequipped. These methods allow you to query set bonus state.

### update_set_bonuses()

Updates all set bonuses based on currently equipped items. Called automatically after equip/unequip operations.

```gdscript
func update_set_bonuses(inventory: PPInventory, character_stats: PPRuntimeStats) -> void
```

**Note:** You typically don't need to call this manually — it's called automatically by `equip_item()` and `unequip_item()`.

---

### get_active_set_bonuses()

Returns active set bonuses with their current tier.

```gdscript
func get_active_set_bonuses(inventory: PPInventory) -> Dictionary
```

**Returns:** Dictionary with `set_id -> tier` (pieces_required of active tier)

**Example:**
```gdscript
var active = PPEquipmentUtils.get_active_set_bonuses(player.inventory)

for set_id in active:
    print("Set %s: tier %d" % [set_id, active[set_id]])
```

---

### get_set_status()

Returns detailed status of a specific equipment set.

```gdscript
func get_set_status(set_entity: PPEquipmentSetEntity, inventory: PPInventory) -> Dictionary
```

**Returns:** Dictionary with keys:
- `equipped_count` (int): Number of set pieces currently equipped
- `total_pieces` (int): Total pieces in the set
- `active_tier` (int): Currently active tier (0 if none)
- `active_bonuses` (Dictionary): Stat bonuses of active tier
- `next_tier` (int): Pieces needed for next tier (0 if at max or none)
- `equipped_piece_ids` (Array[String]): Entity IDs of equipped set pieces

**Example:**
```gdscript
var knight_set = Pandora.get_entity("KNIGHT_SET") as PPEquipmentSetEntity
var status = PPEquipmentUtils.get_set_status(knight_set, player.inventory)

print("Equipped: %d/%d" % [status.equipped_count, status.total_pieces])
print("Active tier: %d" % status.active_tier)

if status.active_bonuses:
    for stat in status.active_bonuses:
        print("  +%d %s" % [status.active_bonuses[stat], stat])

if status.next_tier > 0:
    print("Next tier at %d pieces" % status.next_tier)
```

---

### get_all_equipment_sets()

Returns all equipment set entities defined in Pandora.

```gdscript
func get_all_equipment_sets() -> Array[PPEquipmentSetEntity]
```

**Example:**
```gdscript
var all_sets = PPEquipmentUtils.get_all_equipment_sets()

for set_entity in all_sets:
    print("%s (%d pieces)" % [set_entity.get_set_name(), set_entity.get_total_pieces()])
```

---

### get_sets_for_equipment()

Finds all equipment sets that contain a specific equipment piece.

```gdscript
func get_sets_for_equipment(equipment: PPEquipmentEntity) -> Array[PPEquipmentSetEntity]
```

**Example:**
```gdscript
var helmet = Pandora.get_entity("KNIGHT_HELMET") as PPEquipmentEntity
var sets = PPEquipmentUtils.get_sets_for_equipment(helmet)

for s in sets:
    print("Part of set: %s" % s.get_set_name())
```

---

## Integration with Other Systems

### With PPInventory

Equipment slots are managed by PPInventory:

```gdscript
# PPInventory methods used by PPEquipmentUtils:
inventory.has_item(item)  # Check if item exists
inventory.remove_item(item, 1)  # Remove from inventory
inventory.add_item(item, 1)  # Return to inventory
inventory.has_equipment_in_slot(slot)  # Check slot occupancy
inventory.get_equipped_item(slot)  # Get equipped item
inventory.set_equipped_item(slot, item_slot)  # Set equipment

# PPInventory signals emitted:
inventory.item_equipped.emit(slot, item)
inventory.item_unequipped.emit(slot, item)
```

---

### With PPRuntimeStats

Stat modifiers are automatically managed:

```gdscript
# Equipment creates modifiers with source naming:
# Source format: "equipment_{slot_name}"

# When equipped:
var modifier = PPStatModifier.create_flat(
    "attack",
    sword_stats._attack,
    "equipment_WEAPON"
)
character_stats.add_modifier(modifier)

# When unequipped:
character_stats.remove_modifiers_by_source("equipment_WEAPON")
```

---

### With PPEquipmentEntity

Equipment properties are accessed through entity:

```gdscript
var equipment = Pandora.get_entity("IRON_SWORD") as PPEquipmentEntity

# PPEquipmentUtils uses:
equipment.get_equipment_slot()  # Get slot type
equipment.get_equipment_stats()  # Get stat bonuses
equipment.has_stat_bonuses()  # Check if has stats
```

---

## Best Practices

### ✅ Always Pass Runtime Stats

```gdscript
# ✅ Good: Stat modifiers apply
PPEquipmentUtils.equip_item(inventory, sword, player.runtime_stats)

# ❌ Bad: Stats don't update
inventory.set_equipped_item("WEAPON", sword)
```

---

### ✅ Connect to Signals for Reactive Updates

```gdscript
# ✅ Good: UI updates automatically
PPEquipmentUtils.equipment_equipped.connect(_update_ui)
PPEquipmentUtils.equipment_unequipped.connect(_update_ui)

# ❌ Bad: Manual polling
func _process(delta):
    if equipment_changed:
        _update_ui()
```

---

### ✅ Handle Equipment in Save/Load

```gdscript
# ✅ Good: Reapply equipment on load
func load_game():
    player.inventory = PPInventory.from_dict(save_data["inventory"])
    player.runtime_stats = PPRuntimeStats.from_dict(save_data["stats"])

    # Reapply all equipment stat modifiers
    reapply_equipment_modifiers()

func reapply_equipment_modifiers():
    for slot in player.inventory.equipped_items.keys():
        if player.inventory.has_equipment_in_slot(slot):
            var equipped = player.inventory.get_equipped_item(slot)
            var item = equipped.item as PPEquipmentEntity

            if item and item.has_stat_bonuses():
                _apply_equipment_stats(item, slot, player.runtime_stats)
```

---

### ✅ Validate Items Before Operations

```gdscript
# ✅ Good: Type safety
if PPEquipmentUtils.can_equip(item):
    var equipment = item as PPEquipmentEntity
    PPEquipmentUtils.equip_item(inventory, equipment, stats)

# ❌ Bad: Unsafe casting
var equipment = item as PPEquipmentEntity
PPEquipmentUtils.equip_item(inventory, equipment, stats)  # May crash
```

---

## See Also

- [Equipment System](../core-systems/equipment-system.md) - Complete equipment guide
- [PPEquipmentEntity](../entities/equipment-entity.md) - Equipment entity API
- [PPInventory](../api/inventory.md) - Inventory management
- [PPRuntimeStats](../api/runtime-stats.md) - Stat modifiers
- [PPStatModifier](../api/stat-modifier.md) - Stat modifier API

---

*API Reference for Pandora+ v1.0.1-premium*
