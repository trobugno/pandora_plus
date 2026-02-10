# PPRuntimeItem

**Extends:** `Resource`

Runtime item instance that tracks dynamic per-instance state during gameplay.

---

## Description

`PPRuntimeItem` wraps a `PPItemEntity` to provide per-instance runtime data. While `PPItemEntity` defines the template (shared properties like name, texture, base value), `PPRuntimeItem` tracks instance-specific state.

This enables scenarios where two "Iron Sword" items can have different properties - one renamed, another with different durability.

**Core Features:**
- Unique instance identification
- Custom naming
- Full serialization

**💎 Premium Features:**
- Durability system
- Enchantment system
- Runtime stats with modifiers
- Cooldown tracking

---

## When to Use

| Scenario | Use PPItemEntity | Use PPRuntimeItem |
|----------|------------------|-------------------|
| Generic stackable items (potions, materials) | ✅ | ❌ |
| Unique weapons/armor | ❌ | ✅ |
| 💎 Items with durability | ❌ | ✅ |
| Renamed items | ❌ | ✅ |
| 💎 Enchanted items | ❌ | ✅ |

---

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `item_data` | `Dictionary` | Cached entity data for quick access |

---

## Signals

###### `custom_name_changed(old_name: String, new_name: String)`

Emitted when the custom display name changes.

---

###### 💎 `durability_changed(old_value: int, new_value: int)`

Emitted when durability changes.

---

###### 💎 `item_broken()`

Emitted when durability reaches 0.

---

###### 💎 `item_repaired()`

Emitted when a broken item is repaired.

---

###### 💎 `enchantment_added(enchantment_id: String)`

Emitted when an enchantment is applied.

---

###### 💎 `enchantment_removed(enchantment_id: String)`

Emitted when an enchantment is removed.

---

###### 💎 `cooldown_started(duration: float)`

Emitted when item goes on cooldown.

---

###### 💎 `cooldown_finished()`

Emitted when cooldown ends.

---

## Constructor

###### `PPRuntimeItem(p_item_data: Variant = null)`

Creates a new runtime item instance.

**Parameters:**
- `p_item_data`: Either a `PPItemEntity` (creates new instance) or `Dictionary` (restores from save)

**Example:**
```gdscript
# Create from entity
var sword_entity = Pandora.get_entity("IRON_SWORD") as PPItemEntity
var runtime_sword = PPRuntimeItem.new(sword_entity)

# Restore from saved data
var saved_data = load_from_save()
var restored_sword = PPRuntimeItem.new(saved_data)
```

---

## Methods

### Instance Identification

###### `get_instance_id() -> String`

Returns the unique instance identifier.

```gdscript
var id = runtime_item.get_instance_id()
print(id)  # "1704067200_123456789"
```

---

###### `is_valid() -> bool`

Returns `true` if the runtime item has a valid entity reference.

---

### Custom Name

###### `set_custom_name(new_name: String) -> void`

Sets a custom display name for this specific item instance.

```gdscript
var sword = PPRuntimeItem.new(sword_entity)
sword.set_custom_name("Excalibur")
print(sword.get_display_name())  # "Excalibur"
```

---

###### `get_custom_name() -> String`

Gets the custom name (empty string if not set).

---

###### `has_custom_name() -> bool`

Returns `true` if this item has a custom name.

---

###### `get_display_name() -> String`

Gets the display name (custom name if set, otherwise entity name).

```gdscript
var sword = PPRuntimeItem.new(sword_entity)
print(sword.get_display_name())  # "Iron Sword"

sword.set_custom_name("Dragonslayer")
print(sword.get_display_name())  # "Dragonslayer"
```

---

### Entity Accessors

These methods delegate to the underlying `PPItemEntity`:

| Method | Returns | Description |
|--------|---------|-------------|
| `get_item_entity()` | `PPItemEntity` | The underlying entity |
| `get_entity_id()` | `String` | Entity ID |
| `get_item_name()` | `String` | Original item name |
| `get_description()` | `String` | Item description |
| `get_texture()` | `Texture` | Item texture |
| `is_stackable()` | `bool` | Whether item can stack |
| `get_value()` | `float` | Item value (💎 reduced by durability) |
| `get_weight()` | `float` | Item weight |
| `get_rarity()` | `PPRarityEntity` | Item rarity |

---

### Comparison

###### `is_same_instance(other: PPRuntimeItem) -> bool`

Returns `true` if both runtime items are the exact same instance.

---

###### `is_same_item_type(other: PPRuntimeItem) -> bool`

Returns `true` if both reference the same entity type.

---

###### `can_stack_with(other: PPRuntimeItem) -> bool`

Returns `true` if this item can stack with another in inventory.

**Stacking requires:**
- Same entity type
- Both stackable
- Neither has custom name
- 💎 Neither has durability, enchantments, or stats

---

### 💎 Durability System

> Items need a `max_durability` property defined in Pandora to use durability.

###### `has_durability() -> bool`

Returns `true` if this item has a durability system.

---

###### `get_durability() -> int`

Returns current durability.

---

###### `get_max_durability() -> int`

Returns maximum durability.

---

###### `get_durability_percent() -> float`

Returns durability as percentage (0.0 to 1.0).

```gdscript
var percent = item.get_durability_percent()
durability_bar.value = percent * 100
```

---

###### `is_broken() -> bool`

Returns `true` if item is broken (durability = 0).

---

###### `damage(amount: int = 1) -> void`

Reduces durability. Emits `item_broken` if durability reaches 0.

```gdscript
func on_attack_hit():
    weapon.damage(1)
    if weapon.is_broken():
        show_message("Your weapon broke!")
```

---

###### `repair(amount: int = -1) -> void`

Restores durability. Pass -1 for full repair.

```gdscript
weapon.repair()     # Full repair
weapon.repair(25)   # Partial repair
```

---

###### `set_durability(value: int) -> void`

Sets durability directly (clamped to 0-max).

---

### 💎 Enchantment System

###### `add_enchantment(enchantment_id: String) -> void`

Adds an enchantment to this item.

```gdscript
weapon.add_enchantment("FIRE_DAMAGE")
weapon.add_enchantment("LIFESTEAL")
```

---

###### `remove_enchantment(enchantment_id: String) -> void`

Removes an enchantment.

---

###### `has_enchantment(enchantment_id: String) -> bool`

Returns `true` if item has the specified enchantment.

```gdscript
if weapon.has_enchantment("FIRE_DAMAGE"):
    add_fire_visual_effect()
```

---

###### `get_enchantments() -> Array[String]`

Returns all enchantment IDs.

---

###### `get_enchantment_count() -> int`

Returns number of enchantments.

---

###### `clear_enchantments() -> void`

Removes all enchantments.

---

### 💎 Runtime Stats

###### `has_runtime_stats() -> bool`

Returns `true` if item has runtime stats.

---

###### `get_runtime_stats() -> PPRuntimeStats`

Returns the runtime stats object.

---

###### `add_stat_modifier(modifier: PPStatModifier) -> void`

Adds a stat modifier.

```gdscript
var buff = PPStatModifier.new()
buff.stat_name = "attack"
buff.type = PPStatModifier.ModifierType.ADDITIVE
buff.value = 0.25  # +25%
weapon.add_stat_modifier(buff)
```

---

###### `remove_stat_modifier(modifier: PPStatModifier) -> void`

Removes a stat modifier.

---

###### `get_effective_stat(stat_name: String) -> float`

Gets stat value with all modifiers applied.

```gdscript
var attack = weapon.get_effective_stat("attack")
```

---

### 💎 Cooldown System

###### `is_on_cooldown() -> bool`

Returns `true` if item is on cooldown.

---

###### `get_cooldown_remaining() -> float`

Returns remaining cooldown in seconds.

---

###### `start_cooldown(duration: float) -> void`

Starts a cooldown.

```gdscript
func use_item(item: PPRuntimeItem) -> void:
    if item.is_on_cooldown():
        show_message("Item on cooldown!")
        return
    apply_item_effect(item)
    item.start_cooldown(5.0)
```

---

###### `update_cooldown(delta: float) -> void`

Updates cooldown timer. Call from `_process()`.

```gdscript
func _process(delta: float) -> void:
    for slot in inventory.all_items:
        if slot and slot.has_runtime_item():
            slot.get_runtime_item().update_cooldown(delta)
```

---

###### `reset_cooldown() -> void`

Immediately ends cooldown.

---

### Serialization

###### `to_dict() -> Dictionary`

Converts to dictionary for saving.

```gdscript
var data = runtime_item.to_dict()
save_to_file(data)
```

---

###### `static from_dict(data: Dictionary) -> PPRuntimeItem`

Creates from saved dictionary.

```gdscript
var data = load_from_file()
var runtime_item = PPRuntimeItem.from_dict(data)
```

---

## Integration with Inventory

### Adding Runtime Items

```gdscript
# Create runtime item
var sword = PPRuntimeItem.new(sword_entity)
sword.set_custom_name("My Sword")

# Add to inventory
inventory.add_runtime_item(sword)
```

### Accessing Runtime Items

```gdscript
var slot = inventory.all_items[0]

if slot.has_runtime_item():
    var runtime = slot.get_runtime_item()
    print(runtime.get_display_name())
else:
    print(slot.item.get_item_name())
```

---

## Serialization Format

**Core:**
```json
{
    "entity_id": "IRON_SWORD",
    "instance_id": "1704067200_123456789",
    "custom_name": "Excalibur",
    "item_data": { ... }
}
```

**💎 Premium (additional fields):**
```json
{
    "durability": 75,
    "max_durability": 100,
    "is_broken": false,
    "enchantments": ["FIRE_DAMAGE", "LIFESTEAL"],
    "runtime_stats": { ... },
    "cooldown_remaining": 2.5
}
```

---

## Usage Examples

### Example 1: Named Weapon Drop

```gdscript
func drop_named_weapon(entity_id: String, custom_name: String) -> PPRuntimeItem:
    var entity = Pandora.get_entity(entity_id) as PPItemEntity
    var runtime = PPRuntimeItem.new(entity)
    runtime.set_custom_name(custom_name)
    return runtime

var legendary = drop_named_weapon("IRON_SWORD", "Blade of the Fallen King")
inventory.add_runtime_item(legendary)
```

---

### Example 2: Item Tooltip

```gdscript
func show_tooltip(slot: PPInventorySlot) -> void:
    var name: String
    var lines: Array[String] = []

    if slot.has_runtime_item():
        var runtime = slot.get_runtime_item()
        name = runtime.get_display_name()
        lines.append(runtime.get_description())

        # 💎 Premium: Show durability
        if runtime.has_durability():
            lines.append("Durability: %d/%d" % [
                runtime.get_durability(),
                runtime.get_max_durability()
            ])

        # 💎 Premium: Show enchantments
        for ench_id in runtime.get_enchantments():
            lines.append("[color=purple]+ %s[/color]" % ench_id)
    else:
        name = slot.item.get_item_name()
        lines.append(slot.item.get_description())

    tooltip.show(name, "\n".join(lines))
```

---

### 💎 Example 3: Durability-Based Combat

```gdscript
func attack(weapon: PPRuntimeItem, target: Enemy) -> void:
    if weapon.is_broken():
        show_message("Weapon is broken!")
        return

    var base_damage = weapon.get_effective_stat("attack")
    var durability_mult = 0.5 + (weapon.get_durability_percent() * 0.5)
    var final_damage = base_damage * durability_mult

    target.take_damage(final_damage)
    weapon.damage(1)

    if weapon.get_durability_percent() < 0.25:
        show_warning("Weapon durability low!")
```

---

### 💎 Example 4: Enchantment Effects

```gdscript
func apply_enchantment_effects(weapon: PPRuntimeItem, damage: float) -> float:
    var final_damage = damage

    for ench_id in weapon.get_enchantments():
        match ench_id:
            "FIRE_DAMAGE":
                final_damage += 10
                spawn_fire_effect()
            "CRITICAL_BOOST":
                if randf() < 0.25:
                    final_damage *= 2.0
            "LIFESTEAL":
                heal_player(final_damage * 0.1)

    return final_damage
```

---

## Backward Compatibility

The system is fully backward compatible:

- Existing inventories with only `PPItemEntity` continue to work
- `PPInventorySlot.get_item()` returns the entity in both cases
- Serialization detects and handles both formats
- No migration required for existing save files

---

## See Also

- [PPInventory](inventory.md) - Inventory system
- [PPInventorySlot](inventory-slot.md) - Inventory slot
- [PPItemEntity](../entities/item-entity.md) - Item entity
- [💎PPEquipmentEntity](../entities/equipment-entity.md) - Equipment entity
- [PPRuntimeStats](runtime-stats.md) - Stats system
- [PPStatModifier](stat-modifier.md) - Stat modifiers

---

*API Reference v1.1.0-core | v1.0.0-premium*
