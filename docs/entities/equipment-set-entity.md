# 💎 PPEquipmentSetEntity

**Extends:** `PandoraEntity`

Defines an equipment set with pieces and tiered stat bonuses.

**Availability:** 💎 Premium

---

## Description

`PPEquipmentSetEntity` represents an equipment set — a collection of `PPEquipmentEntity` pieces that grant bonus stats when multiple pieces are equipped simultaneously. Sets support multiple bonus tiers (e.g., 2-piece bonus, 4-piece bonus).

Set bonuses are automatically managed by `PPEquipmentUtils` when equipment is equipped or unequipped.

---

## Properties

Equipment set entities have these Pandora properties:

| Property | Type | Description |
|----------|------|-------------|
| `set_name` | `String` | Display name of the set |
| `set_description` | `String` | Description of the set |
| `set_pieces` | `Array[Reference]` | References to PPEquipmentEntity pieces |
| `set_bonuses` | `PPSetBonus` | Tiered bonuses (pieces required + stat bonuses) |

---

## Methods

### get_set_name()

Returns the display name of this set.

```gdscript
func get_set_name() -> String
```

**Example:**
```gdscript
var knight_set = Pandora.get_entity("KNIGHT_SET") as PPEquipmentSetEntity
print("Set: ", knight_set.get_set_name())  # "Knight's Honor"
```

---

### get_set_description()

Returns the description of this set.

```gdscript
func get_set_description() -> String
```

---

### get_set_pieces()

Returns the entity IDs of all equipment pieces in this set.

```gdscript
func get_set_pieces() -> Array[String]
```

**Returns:** Array of entity IDs (e.g., `["KNIGHT_HELMET", "KNIGHT_ARMOR", "KNIGHT_BOOTS"]`)

**Example:**
```gdscript
var pieces = knight_set.get_set_pieces()
for piece_id in pieces:
    var piece = Pandora.get_entity(piece_id) as PPEquipmentEntity
    print("  %s (%s)" % [piece.get_item_name(), piece.get_equipment_slot()])
```

---

### get_set_bonuses()

Returns the set bonus data containing all tiers.

```gdscript
func get_set_bonuses() -> PPSetBonus
```

**Returns:** PPSetBonus instance or `null` if no bonuses defined

---

### get_bonus_for_count()

Gets the best applicable bonus tier for a given equipped piece count.

```gdscript
func get_bonus_for_count(count: int) -> PPSetBonusEntry
```

**Parameters:**
- `count`: Number of set pieces currently equipped

**Returns:** PPSetBonusEntry for the best tier, or `null` if no tier applies

**Example:**
```gdscript
# If set has tiers at 2 and 4 pieces:
var tier = knight_set.get_bonus_for_count(3)
# Returns the 2-piece tier (best applicable for 3 equipped)

var tier2 = knight_set.get_bonus_for_count(4)
# Returns the 4-piece tier

var tier0 = knight_set.get_bonus_for_count(1)
# Returns null (no tier for 1 piece)
```

---

### get_total_pieces()

Returns the total number of pieces in this set.

```gdscript
func get_total_pieces() -> int
```

---

## Usage Examples

### Example 1: Display Set Information

```gdscript
func display_set_info(set_entity: PPEquipmentSetEntity, inventory: PPInventory):
    print("=== %s ===" % set_entity.get_set_name())
    print(set_entity.get_set_description())

    # List pieces
    var pieces = set_entity.get_set_pieces()
    print("\nPieces (%d total):" % pieces.size())
    for piece_id in pieces:
        var piece = Pandora.get_entity(piece_id) as PPEquipmentEntity
        var equipped = "✓" if _is_piece_equipped(piece, inventory) else " "
        print("  [%s] %s (%s)" % [equipped, piece.get_item_name(), piece.get_equipment_slot()])

    # List bonus tiers
    var bonuses = set_entity.get_set_bonuses()
    if bonuses:
        print("\nSet Bonuses:")
        for entry in bonuses.get_entries():
            var required = entry.get_pieces_required()
            var stats = entry.get_stat_bonuses()
            var bonus_text = ", ".join(stats.keys().map(func(s): return "+%d %s" % [stats[s], s]))
            print("  %d pieces: %s" % [required, bonus_text])

func _is_piece_equipped(piece: PPEquipmentEntity, inventory: PPInventory) -> bool:
    var slot = piece.get_equipment_slot()
    if inventory.has_equipment_in_slot(slot):
        return inventory.get_equipped_item(slot).item.get_entity_id() == piece.get_entity_id()
    return false
```

---

### Example 2: Set Bonus Tooltip

```gdscript
func build_set_tooltip(set_entity: PPEquipmentSetEntity, inventory: PPInventory) -> String:
    var status = PPEquipmentUtils.get_set_status(set_entity, inventory)
    var text = "%s (%d/%d)\n" % [set_entity.get_set_name(), status.equipped_count, status.total_pieces]

    var bonuses = set_entity.get_set_bonuses()
    if bonuses:
        for entry in bonuses.get_entries():
            var required = entry.get_pieces_required()
            var stats = entry.get_stat_bonuses()
            var active = " [ACTIVE]" if required == status.active_tier else ""
            text += "\n(%d) Set Bonus%s:" % [required, active]
            for stat in stats:
                text += "\n  +%d %s" % [stats[stat], stat]

    return text
```

---

## Creating Equipment Sets in Pandora Editor

### Step 1: Create Equipment Pieces

First, create the individual equipment pieces as PPEquipmentEntity items (see [PPEquipmentEntity](equipment-entity.md)).

### Step 2: Create Set Entity

1. Open Pandora Editor
2. Navigate to "EquipmentSets" category
3. Create a new entity
4. Fill in `set_name` and `set_description`
5. Add references to equipment pieces in `set_pieces`
6. Define bonus tiers in `set_bonuses`:
   - Click "Edit" to open the tiers editor
   - Add tiers with pieces required and stat bonuses

### Step 3: Bonuses Apply Automatically

No additional code needed — PPEquipmentUtils handles set bonus activation/deactivation when equipment is equipped or unequipped.

---

## See Also

- [Equipment System](../core-systems/equipment-system.md) - Complete equipment guide
- [PPEquipmentEntity](equipment-entity.md) - Equipment item entity
- [PPEquipmentUtils](../utilities/equipment-utils.md) - Equipment utility functions
- [PPRuntimeStats](../api/runtime-stats.md) - Stat modifiers

---

*API Reference for Pandora+ v1.0.1-premium*
