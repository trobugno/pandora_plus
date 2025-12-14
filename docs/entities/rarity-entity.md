# PPRarityEntity

**Extends:** `PandoraEntity`

Represents a rarity tier for items, used for categorization, drop rates, and visual styling.

---

## Description

`PPRarityEntity` defines rarity tiers (e.g., Common, Rare, Legendary) with associated drop chance percentages. Items reference rarity entities to determine their scarcity and value.

Rarities are typically used for:
- Color-coding items in UI
- Calculating loot drop chances
- Sorting/filtering items
- Determining item value scaling

---

## Properties

Rarities have these standard properties (stored in Pandora):

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Display name of the rarity tier |
| `percentage` | `float` | Drop chance percentage (0-100) |

> 💡 These properties are defined in Pandora's data system and accessed via getter methods.

---

## Methods

###### `get_rarity_name() -> String`

Returns the display name of the rarity tier.

**Returns:** Rarity name as String

**Example:**
```gdscript
var legendary = Pandora.get_entity("LEGENDARY") as PPRarityEntity
print(legendary.get_rarity_name())  # "Legendary"
```

**Common Rarity Names:**
- `"Common"` - Most frequent items
- `"Uncommon"` - Less common items
- `"Rare"` - Rare finds
- `"Epic"` - Very rare items
- `"Legendary"` - Extremely rare items
- `"Mythic"` - Rarest of all

---

###### `get_percentage() -> float`

Returns the drop chance percentage for this rarity.

**Returns:** Percentage as float (0-100)

**Example:**
```gdscript
var rare = Pandora.get_entity("RARE") as PPRarityEntity
print("Drop chance: ", rare.get_percentage(), "%")  # 5.0%

# Use in loot calculation
if randf() * 100.0 <= rare.get_percentage():
    print("Rare item dropped!")
```

**Typical Values:**
- Common: `70-80%`
- Uncommon: `15-20%`
- Rare: `5-10%`
- Epic: `1-3%`
- Legendary: `0.1-1%`
- Mythic: `< 0.1%`

---

## Creating Rarities in Pandora

### In Pandora Editor

1. Open **Pandora Editor**
2. Go to **Rarity** category
3. Click **Create Entity**
4. Select **PPRarityEntity** as type
5. Fill in properties:

```
Entity ID: LEGENDARY
Type: PPRarityEntity

Properties:
├── name: "Legendary"
└── percentage: 0.5
```

### Common Rarity Setup

Create a standard rarity system:

```gdscript
# Common
ID: COMMON
name: "Common"
percentage: 75.0

# Uncommon
ID: UNCOMMON
name: "Uncommon"
percentage: 18.0

# Rare
ID: RARE
name: "Rare"
percentage: 5.0

# Epic
ID: EPIC
name: "Epic"
percentage: 1.5

# Legendary
ID: LEGENDARY
name: "Legendary"
percentage: 0.5
```

---

## Common Patterns

### Pattern 1: Rarity Tiers Enum

```gdscript
# Create helper enum for type safety
enum RarityTier {
    COMMON,
    UNCOMMON,
    RARE,
    EPIC,
    LEGENDARY,
    MYTHIC
}

# Map to Pandora entities
var RARITIES = {}

func _ready():
    RARITIES[RarityTier.COMMON] = Pandora.get_entity("COMMON") as PPRarityEntity
    RARITIES[RarityTier.UNCOMMON] = Pandora.get_entity("UNCOMMON") as PPRarityEntity
    RARITIES[RarityTier.RARE] = Pandora.get_entity("RARE") as PPRarityEntity
    RARITIES[RarityTier.EPIC] = Pandora.get_entity("EPIC") as PPRarityEntity
    RARITIES[RarityTier.LEGENDARY] = Pandora.get_entity("LEGENDARY") as PPRarityEntity
    RARITIES[RarityTier.MYTHIC] = Pandora.get_entity("MYTHIC") as PPRarityEntity

# Usage
var legendary_rarity = RARITIES[RarityTier.LEGENDARY]
```

---

### Pattern 2: Rarity Multipliers

```gdscript
func get_value_multiplier(rarity: PPRarityEntity) -> float:
    if not rarity:
        return 1.0
    
    match rarity.get_rarity_name():
        "Common": return 1.0
        "Uncommon": return 1.5
        "Rare": return 3.0
        "Epic": return 6.0
        "Legendary": return 12.0
        "Mythic": return 25.0
        _: return 1.0

# Apply to item value
func calculate_item_value(item: PPItemEntity) -> float:
    var base_value = item.get_value()
    var rarity = item.get_rarity()
    var multiplier = get_value_multiplier(rarity)
    return base_value * multiplier
```

---

### Pattern 3: Rarity Filter

```gdscript
class_name RarityFilter

static func filter_by_min_rarity(
    items: Array[PPItemEntity],
    min_tier: String
) -> Array[PPItemEntity]:
    var tier_order = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"]
    var min_index = tier_order.find(min_tier)
    
    if min_index < 0:
        return items  # Invalid tier, return all
    
    var filtered: Array[PPItemEntity] = []
    
    for item in items:
        var rarity = item.get_rarity()
        if not rarity:
            continue
        
        var item_index = tier_order.find(rarity.get_rarity_name())
        if item_index >= min_index:
            filtered.append(item)
    
    return filtered

# Usage: get only Rare and above
var rare_items = RarityFilter.filter_by_min_rarity(all_items, "Rare")
```

---

## Best Practices

### ✅ Always Check for Null

```gdscript
# ✅ Good
var item = Pandora.get_entity("SWORD") as PPItemEntity
var rarity = item.get_rarity()
if rarity:
    print("Rarity: ", rarity.get_rarity_name())
else:
    print("No rarity set")

# ❌ Bad
var item = Pandora.get_entity("SWORD") as PPItemEntity
print(item.get_rarity().get_rarity_name())  # Crash if null!
```

---

### ✅ Use Consistent Naming

```gdscript
# ✅ Good: consistent capitalization
"Common", "Uncommon", "Rare", "Epic", "Legendary"

# ❌ Bad: inconsistent
"common", "Uncommon", "RARE", "epic"
```

---

### ✅ Percentage Sum ≠ 100%

```gdscript
# ✅ Percentages don't need to sum to 100%
# They represent individual drop chances

Common: 75%      # 75% chance to drop common
Rare: 5%         # 5% chance to drop rare
Legendary: 0.5%  # 0.5% chance to drop legendary

# Multiple items can drop from one source!
```

---

### ✅ Cache Rarity References

```gdscript
# ✅ Good: cache
var LEGENDARY_RARITY: PPRarityEntity

func _ready():
    LEGENDARY_RARITY = Pandora.get_entity("LEGENDARY") as PPRarityEntity

func is_legendary(item: PPItemEntity) -> bool:
    return item.get_rarity() == LEGENDARY_RARITY

# ❌ Bad: load every time
func is_legendary(item: PPItemEntity) -> bool:
    var legendary = Pandora.get_entity("LEGENDARY") as PPRarityEntity
    return item.get_rarity() == legendary
```

---

## Integration with Other Systems

### With PPItemEntity

```gdscript
# Link item to rarity
var item = Pandora.get_entity("MAGIC_SWORD") as PPItemEntity
var rarity = Pandora.get_entity("RARE") as PPRarityEntity

# In Pandora Editor:
# item.rarity = [reference to RARE]

# In code:
print("%s is %s (%.1f%% drop)" % [
    item.get_item_name(),
    item.get_rarity().get_rarity_name(),
    item.get_rarity().get_percentage()
])
```

---

## Standard Rarity Setup

### Recommended Default Values

```gdscript
# Create these in Pandora Editor:

COMMON:
  name: "Common"
  percentage: 70.0
  color: #FFFFFF (white)

UNCOMMON:
  name: "Uncommon"
  percentage: 20.0
  color: #00FF00 (green)

RARE:
  name: "Rare"
  percentage: 7.0
  color: #0080FF (blue)

EPIC:
  name: "Epic"
  percentage: 2.5
  color: #A020F0 (purple)

LEGENDARY:
  name: "Legendary"
  percentage: 0.5
  color: #FFA500 (orange)

MYTHIC:
  name: "Mythic"
  percentage: 0.1
  color: #FF0000 (red)
```

> 💡 Note: Color is not stored in `PPRarityEntity` but can be added as a custom property if needed.

---

## Notes

### Percentage Interpretation

The `percentage` field can be interpreted in different ways:

1. **Drop Chance**: Probability this item drops (0-100%)
2. **Relative Weight**: Used in weighted random selection
3. **Rarity Tier**: Just for display/sorting (value doesn't matter)

Choose the interpretation that fits your game design.

---

### Multiple Rarities

An item can only have **one** rarity. If you need items with multiple properties:

```gdscript
# ❌ Can't do this
item.rarities = [RARE, MAGICAL, CURSED]

# ✅ Use custom properties instead
item.set_bool("is_magical", true)
item.set_bool("is_cursed", true)
var rarity = item.get_rarity()  # Still just one rarity
```

---

### @tool Annotation

The `@tool` annotation allows the script to run in the editor for:
- Preview rarities in Pandora Editor
- Edit properties visually
- See changes in real-time

---

## See Also

- [PPItemEntity](../entities/item-entity.md) - Item system
- [Inventory System](../core-systems/inventory.md) - Item storage
- [Pandora Documentation](https://bitbra.in/pandora) - Base entity system

---

*API Reference generated from source code version 0.3.0-beta*