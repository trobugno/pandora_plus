# PPQuestReward

**Extends:** `RefCounted`

Static quest reward definition containing reward type, quantities, and item references.

---

## Description

`PPQuestReward` is a property class that defines rewards given to the player upon quest completion. It supports multiple reward types including items, currency, and experience points.

Rewards are attached to `PPQuest` and granted when the quest is completed. The reward system is flexible, allowing for combinations of different reward types in a single quest.

---

## Enums

### RewardType

Defines the type of reward to grant.

| Value | Description |
|-------|-------------|
| `ITEM` | Give item(s) to player inventory |
| `CURRENCY` | Give gold/currency |
| `EXPERIENCE` | Give experience points |

---

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `_reward_name` | `String` | Display name of the reward |
| `_reward_type` | `int` | Reward type from `RewardType` enum |
| `_reward_entity_reference` | `PandoraReference` | Reference to reward entity (for ITEM rewards) |
| `_quantity` | `int` | Quantity of items (for ITEM rewards) |
| `_currency_amount` | `int` | Amount of currency (for CURRENCY rewards) |
| `_experience_amount` | `int` | Amount of experience (for EXPERIENCE rewards) |

---

## Constructor

###### `PPQuestReward(reward_name: String = "", reward_type: int = RewardType.ITEM, reward_entity_reference: PandoraReference = null, quantity: int = 1, currency_amount: int = 0, experience_amount: int = 0)`

Creates a new quest reward with specified parameters.

**Parameters:**
- `reward_name`: Display name for the reward
- `reward_type`: Type from `RewardType` enum (default: `ITEM`)
- `reward_entity_reference`: Entity reference (for items)
- `quantity`: Number of items (default: 1)
- `currency_amount`: Currency amount (default: 0)
- `experience_amount`: XP amount (default: 0)

**Example:**
```gdscript
# Item reward
var sword_ref = PandoraReference.new("IRON_SWORD", PandoraReference.Type.ENTITY)
var item_reward = PPQuestReward.new(
    "Iron Sword",
    PPQuestReward.RewardType.ITEM,
    sword_ref,
    1,
    0,
    0
)

# Currency reward
var gold_reward = PPQuestReward.new(
    "Gold Coins",
    PPQuestReward.RewardType.CURRENCY,
    null,
    0,
    100,  # 100 gold
    0
)

# Experience reward
var xp_reward = PPQuestReward.new(
    "Quest XP",
    PPQuestReward.RewardType.EXPERIENCE,
    null,
    0,
    0,
    250  # 250 XP
)
```

---

## Methods

### Getters

###### `get_reward_name() -> String`

Returns the reward display name.

---

###### `get_reward_type() -> int`

Returns the reward type from `RewardType` enum.

---

###### `get_reward_entity_reference() -> PandoraReference`

Returns the reference to the reward entity (for item rewards).

---

###### `get_reward_entity() -> PandoraEntity`

Returns the actual reward entity (resolves the reference).

**Example:**
```gdscript
var entity = reward.get_reward_entity()
if entity is PPItemEntity:
    print("Reward: %s" % entity.get_item_name())
```

---

###### `get_quantity() -> int`

Returns the quantity of items to reward.

---

###### `get_currency_amount() -> int`

Returns the amount of currency to reward.

---

###### `get_experience_amount() -> int`

Returns the amount of experience to reward.

---

### Setters

All properties have corresponding setter methods:
- `set_reward_name(reward_name: String)`
- `set_reward_type(reward_type: int)`
- `set_reward_entity_reference(reference: PandoraReference)`
- `set_quantity(quantity: int)`
- `set_currency_amount(amount: int)`
- `set_experience_amount(amount: int)`

---

### Serialization

###### `load_data(data: Dictionary) -> void`

Loads reward data from a dictionary.

**Parameters:**
- `data`: Dictionary containing serialized reward data

---

###### `save_data(fields_settings: Array[Dictionary]) -> Dictionary`

Serializes reward data to a dictionary.

**Parameters:**
- `fields_settings`: Field configuration array

**Returns:** Dictionary with reward data

---

## Usage Example

### Example: Creating Multiple Reward Types

```gdscript
extends Node

func create_quest_rewards() -> Array[PPQuestReward]:
    var rewards: Array[PPQuestReward] = []

    # Item reward
    var potion_ref = PandoraReference.new("HEALTH_POTION", PandoraReference.Type.ENTITY)
    var potion_reward = PPQuestReward.new(
        "Health Potions",
        PPQuestReward.RewardType.ITEM,
        potion_ref,
        3,  # 3 potions
        0,
        0
    )
    rewards.append(potion_reward)

    # Currency reward
    var gold_reward = PPQuestReward.new(
        "Gold Reward",
        PPQuestReward.RewardType.CURRENCY,
        null,
        0,
        150,  # 150 gold
        0
    )
    rewards.append(gold_reward)

    # Experience reward
    var xp_reward = PPQuestReward.new(
        "Quest Experience",
        PPQuestReward.RewardType.EXPERIENCE,
        null,
        0,
        0,
        500  # 500 XP
    )
    rewards.append(xp_reward)

    return rewards

func grant_rewards_to_player(rewards: Array[PPQuestReward], player: Node):
    for reward in rewards:
        match reward.get_reward_type():
            PPQuestReward.RewardType.ITEM:
                var item = reward.get_reward_entity()
                var qty = reward.get_quantity()
                player.inventory.add_item(item, qty)
                print("Received: %dx %s" % [qty, item.get_item_name()])

            PPQuestReward.RewardType.CURRENCY:
                var amount = reward.get_currency_amount()
                player.inventory.game_currency += amount
                print("Received: %d gold" % amount)

            PPQuestReward.RewardType.EXPERIENCE:
                var xp = reward.get_experience_amount()
                player.add_experience(xp)
                print("Received: %d XP" % xp)
```

---

## Best Practices

### ✅ Use Descriptive Reward Names

```gdscript
# ✅ Good: Clear and descriptive
var reward1 = PPQuestReward.new(
    "Enchanted Steel Sword",
    PPQuestReward.RewardType.ITEM,
    sword_ref,
    1
)

var reward2 = PPQuestReward.new(
    "Quest Completion Gold",
    PPQuestReward.RewardType.CURRENCY,
    null,
    0,
    200
)

# ❌ Bad: Vague names
var reward3 = PPQuestReward.new("Reward", PPQuestReward.RewardType.ITEM, sword_ref, 1)
```

---

### ✅ Balance Reward Amounts

```gdscript
# ✅ Good: Balanced for quest difficulty
var easy_quest_reward = PPQuestReward.new(
    "Small Pouch",
    PPQuestReward.RewardType.CURRENCY,
    null,
    0,
    50,  # Low amount for easy quest
    0
)

var hard_quest_reward = PPQuestReward.new(
    "Treasure Chest",
    PPQuestReward.RewardType.CURRENCY,
    null,
    0,
    500,  # Higher amount for difficult quest
    0
)

# ❌ Bad: Unbalanced rewards
var trivial_quest = PPQuestReward.new("Too Much", PPQuestReward.RewardType.CURRENCY, null, 0, 10000, 0)
```

---

### ✅ Combine Multiple Reward Types

```gdscript
# ✅ Good: Mix of rewards for completion
var quest = PPQuest.new("MAIN_001", "Save the Village", "...")

# Add multiple reward types
quest.add_reward(PPQuestReward.new(
    "Hero's Blade",
    PPQuestReward.RewardType.ITEM,
    blade_ref,
    1
))

quest.add_reward(PPQuestReward.new(
    "Village Gratitude",
    PPQuestReward.RewardType.CURRENCY,
    null,
    0,
    300
))

quest.add_reward(PPQuestReward.new(
    "Heroic Deed",
    PPQuestReward.RewardType.EXPERIENCE,
    null,
    0,
    0,
    1000
))
```

---

## Common Patterns

### Pattern 1: Tiered Rewards

```gdscript
# Create rewards based on quest tier
func create_tiered_rewards(tier: int) -> Array[PPQuestReward]:
    var rewards: Array[PPQuestReward] = []

    match tier:
        1:  # Bronze
            rewards.append(PPQuestReward.new(
                "Bronze Reward",
                PPQuestReward.RewardType.CURRENCY,
                null, 0, 50, 0
            ))
            rewards.append(PPQuestReward.new(
                "XP",
                PPQuestReward.RewardType.EXPERIENCE,
                null, 0, 0, 100
            ))
        2:  # Silver
            rewards.append(PPQuestReward.new(
                "Silver Reward",
                PPQuestReward.RewardType.CURRENCY,
                null, 0, 150, 0
            ))
            rewards.append(PPQuestReward.new(
                "XP",
                PPQuestReward.RewardType.EXPERIENCE,
                null, 0, 0, 300
            ))
        3:  # Gold
            rewards.append(PPQuestReward.new(
                "Gold Reward",
                PPQuestReward.RewardType.CURRENCY,
                null, 0, 500, 0
            ))
            rewards.append(PPQuestReward.new(
                "XP",
                PPQuestReward.RewardType.EXPERIENCE,
                null, 0, 0, 1000
            ))

    return rewards
```

---

### Pattern 2: Choice Rewards

```gdscript
# Let player choose one reward from multiple options
func create_choice_rewards() -> Array[PPQuestReward]:
    return [
        PPQuestReward.new(
            "Warrior's Sword",
            PPQuestReward.RewardType.ITEM,
            sword_ref,
            1
        ),
        PPQuestReward.new(
            "Mage's Staff",
            PPQuestReward.RewardType.ITEM,
            staff_ref,
            1
        ),
        PPQuestReward.new(
            "Rogue's Dagger",
            PPQuestReward.RewardType.ITEM,
            dagger_ref,
            1
        )
    ]

# Player chooses one
func grant_chosen_reward(choice_index: int, rewards: Array, player):
    var reward = rewards[choice_index]
    var item = reward.get_reward_entity()
    player.inventory.add_item(item, reward.get_quantity())
```

---

### Pattern 3: Random Rewards

```gdscript
# Grant random reward from pool
func grant_random_reward(player: Node):
    var possible_items = [
        "COMMON_SWORD",
        "COMMON_SHIELD",
        "HEALTH_POTION",
        "MANA_POTION"
    ]

    var random_item_id = possible_items[randi() % possible_items.size()]
    var item_ref = PandoraReference.new(random_item_id, PandoraReference.Type.ENTITY)

    var reward = PPQuestReward.new(
        "Random Reward",
        PPQuestReward.RewardType.ITEM,
        item_ref,
        1
    )

    var item = reward.get_reward_entity()
    player.inventory.add_item(item, 1)
```

---

## Notes

### Reward Types

Each reward type serves different purposes:
- **ITEM**: Tangible gear, consumables, or quest items
- **CURRENCY**: In-game money for purchasing
- **EXPERIENCE**: Character progression

### Null References

For CURRENCY and EXPERIENCE rewards, `reward_entity_reference` should be `null` since they don't reference specific entities.

### Multiple Rewards

A single quest can have multiple rewards. Add them all to the quest using `quest.add_reward()`.

---

## See Also

- [PPQuest](../api/quest.md) - Quest container
- [PPQuestObjective](../api/quest-objective.md) - Quest objectives
- [PPRuntimeQuest](../api/runtime-quest.md) - Runtime quest tracking
- [Quest System](../core-systems/quest-system.md) - Complete system overview

---

*API Reference generated from source code*
