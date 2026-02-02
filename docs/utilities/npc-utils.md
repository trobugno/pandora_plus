# PPNPCUtils

Utility autoload providing comprehensive NPC management functions including lifecycle, combat operations, quest integration, filtering, and analytics.

---

## Overview

`PPNPCUtils` is an autoloaded singleton that provides helper functions for working with NPCs in Pandora+. It handles NPC spawning, combat, quest giving, location tracking, and more.

**Access:** `PPNPCUtils` (globally available)

---

## Signals

### Combat Signals

```gdscript
signal npc_died(npc: PPRuntimeNPC)
signal npc_revived(npc: PPRuntimeNPC)
```

Emitted when NPCs die or are revived.

**Example:**
```gdscript
PPNPCUtils.npc_died.connect(_on_npc_died)

func _on_npc_died(npc: PPRuntimeNPC):
    print("%s has died!" % npc.get_npc_name())
    drop_loot(npc)
```

### Quest Signals

```gdscript
signal npc_has_quest_available(npc: PPRuntimeNPC, quest_count: int)
```

Emitted when checking if NPC has available quests.

**Example:**
```gdscript
PPNPCUtils.npc_has_quest_available.connect(_on_quest_available)

func _on_quest_available(npc: PPRuntimeNPC, count: int):
    print("%s has %d quests" % [npc.get_npc_name(), count])
    show_quest_marker(npc)
```

### 💎 Premium Signals

**Premium Only**

#### Reputation Signals

```gdscript
signal reputation_threshold_reached(npc: PPRuntimeNPC, level: String)
signal faction_reputation_changed(faction: String, average_reputation: float)
```

Emitted when reputation changes cross thresholds.

**Example:**
```gdscript
PPNPCUtils.reputation_threshold_reached.connect(_on_reputation_changed)

func _on_reputation_changed(npc: PPRuntimeNPC, level: String):
    print("%s reputation: %s" % [npc.get_npc_name(), level])
    if level == "Allied":
        unlock_special_merchant_items(npc)
```

#### Trading Signals

```gdscript
signal merchant_transaction_completed(merchant: PPRuntimeNPC, item: PPItemEntity, quantity: int, price: int, transaction_type: String)
signal merchant_transaction_failed(reason: String)
```

Emitted when trading with merchants.

**Example:**
```gdscript
PPNPCUtils.merchant_transaction_completed.connect(_on_trade_complete)

func _on_trade_complete(merchant, item, qty, price, type):
    print("%s %d %s for %d gold" % [type, qty, item.get_item_name(), price])
```

#### Schedule Signals

```gdscript
signal npc_schedule_updated(npc: PPRuntimeNPC)
```

Emitted when NPC schedule updates (location/activity changes).

**Example:**
```gdscript
PPNPCUtils.npc_schedule_updated.connect(_on_schedule_updated)

func _on_schedule_updated(npc: PPRuntimeNPC):
    print("%s is now %s" % [npc.get_npc_name(), npc.get_current_activity()])
    update_npc_position(npc)
```

---

## NPC Lifecycle & Management

### spawn_npc()

Creates a runtime NPC instance from an NPC entity.

```gdscript
func spawn_npc(npc_entity: PPNPCEntity) -> PPRuntimeNPC
```

**Parameters:**
- `npc_entity`: NPC entity to spawn

**Returns:** `PPRuntimeNPC` instance or `null` if entity is invalid

**Example:**
```gdscript
var npc_entity = Pandora.get_entity("npc_village_elder") as PPNPCEntity
var runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

if runtime_npc:
    print("Spawned: ", runtime_npc.get_npc_name())
    add_npc_to_scene(runtime_npc)
```

---

### despawn_npc()

Despawns an NPC (cleanup).

```gdscript
func despawn_npc(runtime_npc: PPRuntimeNPC) -> void
```

**Note:** This is mainly for symmetry with `spawn_npc()`. Actual cleanup logic should be implemented by your game.

**Example:**
```gdscript
PPNPCUtils.despawn_npc(runtime_npc)
remove_npc_from_scene(runtime_npc)
```

---

### get_npcs_at_location()

Finds NPCs at a specific location.

```gdscript
func get_npcs_at_location(npcs: Array, location_ref: PandoraReference) -> Array
```

**Parameters:**
- `npcs`: Array of runtime NPCs
- `location_ref`: Location reference

**Returns:** Array of NPCs at that location

**Example:**
```gdscript
var all_npcs = get_all_spawned_npcs()
var town_ref = PandoraReference.new("town_square", PandoraReference.Type.ENTITY)
var npcs_in_town = PPNPCUtils.get_npcs_at_location(all_npcs, town_ref)

print("%d NPCs in town square" % npcs_in_town.size())
```

---

### find_npc_by_id()

Finds an NPC by entity ID.

```gdscript
func find_npc_by_id(npcs: Array, npc_id: String) -> PPRuntimeNPC
```

**Example:**
```gdscript
var npc = PPNPCUtils.find_npc_by_id(all_npcs, "npc_blacksmith")
if npc:
    print("Found: ", npc.get_npc_name())
```

---

### find_npc_by_name()

Finds an NPC by name.

```gdscript
func find_npc_by_name(npcs: Array, npc_name: String) -> PPRuntimeNPC
```

**Example:**
```gdscript
var elder = PPNPCUtils.find_npc_by_name(all_npcs, "Village Elder")
```

---

## Combat Operations

### damage_npc()

Applies damage to an NPC.

```gdscript
func damage_npc(runtime_npc: PPRuntimeNPC, amount: float, source: String = "unknown") -> void
```

**Parameters:**
- `runtime_npc`: NPC to damage
- `amount`: Damage amount
- `source`: Damage source (for tracking)

**Example:**
```gdscript
# Player attacks NPC with sword
PPNPCUtils.damage_npc(enemy_npc, 25.0, "player_sword")

# Environmental damage
PPNPCUtils.damage_npc(npc, 10.0, "fire_trap")
```

---

### heal_npc()

Heals an NPC.

```gdscript
func heal_npc(runtime_npc: PPRuntimeNPC, amount: float) -> void
```

**Example:**
```gdscript
# Heal NPC by 50 HP
PPNPCUtils.heal_npc(friendly_npc, 50.0)
```

---

### kill_npc()

Kills an NPC immediately.

```gdscript
func kill_npc(runtime_npc: PPRuntimeNPC) -> void
```

**Note:** Emits `npc_died` signal.

**Example:**
```gdscript
# Instant death (scripted event)
PPNPCUtils.kill_npc(doomed_npc)
```

---

### revive_npc()

Revives an NPC with specified health percentage.

```gdscript
func revive_npc(runtime_npc: PPRuntimeNPC, health_percentage: float = 1.0) -> void
```

**Parameters:**
- `runtime_npc`: NPC to revive
- `health_percentage`: Health percentage (0.0 to 1.0)

**Note:** Emits `npc_revived` signal.

**Example:**
```gdscript
# Revive at full health
PPNPCUtils.revive_npc(npc, 1.0)

# Revive at 50% health
PPNPCUtils.revive_npc(npc, 0.5)
```

---

### can_engage_combat()

Checks if NPC can engage in combat.

```gdscript
func can_engage_combat(runtime_npc: PPRuntimeNPC, player_reputation: int = 0) -> bool  # 💎 Premium parameter
```

**Parameters:**
- `runtime_npc`: NPC to check
- 💎 `player_reputation`: Player's reputation with NPC (Premium: affects hostility)

**Returns:** `true` if NPC can be fought

💎 **Premium behavior:** Checks reputation level. NPCs with reputation < -25 (Unfriendly or worse) can be fought.

**Example:**
```gdscript
# Core usage
if PPNPCUtils.can_engage_combat(npc):
    start_combat_with(npc)

# 💎 Premium: Reputation-based combat
var reputation = npc.get_reputation()
if PPNPCUtils.can_engage_combat(npc, reputation):
    start_combat_with(npc)
else:
    print("NPC is not hostile (reputation: %d)" % reputation)
```

---

### can_interact_with_npc()

Checks if player can interact with NPC.

```gdscript
func can_interact_with_npc(runtime_npc: PPRuntimeNPC) -> bool
```

**Returns:** `true` if NPC can be interacted with

💎 **Premium checks:**
- NPC is not sleeping (respects schedule)
- NPC reputation >= 0 (not hostile)

**Example:**
```gdscript
if PPNPCUtils.can_interact_with_npc(npc):
    show_dialogue_ui(npc)
else:
    # 💎 Premium: Check specific reason
    if npc.get_current_activity() == "sleep":
        print("NPC is sleeping. Come back later.")
    elif npc.get_reputation() < 0:
        print("NPC is hostile!")
    else:
        print("Cannot interact")
```

---

## Quest Integration

### get_available_quests_from_npc()

Gets available quests from an NPC.

```gdscript
func get_available_quests_from_npc(
    runtime_npc: PPRuntimeNPC,
    player_level: int,  # 💎 Premium parameter
    completed_quest_ids: Array
) -> Array
```

**Parameters:**
- `runtime_npc`: NPC to check for quests
- 💎 `player_level`: Player's current level (Premium: validates level requirements)
- `completed_quest_ids`: Array of completed quest IDs

**Returns:** Array of available `PPQuestEntity`

**Example:**
```gdscript
var completed = PPQuestManager.get_completed_quest_ids()

# Core usage
var quests = PPNPCUtils.get_available_quests_from_npc(runtime_npc, 1, completed)

# 💎 Premium: Filter by player level
var player_level = PPPlayerManager.get_player_data().level
var quests = PPNPCUtils.get_available_quests_from_npc(runtime_npc, player_level, completed)

for quest_entity in quests:
    var quest = quest_entity.get_quest_data()
    print("- ", quest.get_quest_name())
```

---

### get_quest_givers()

Gets all quest givers from NPC list.

```gdscript
func get_quest_givers(npcs: Array) -> Array
```

**Example:**
```gdscript
var all_npcs = get_spawned_npcs()
var quest_givers = PPNPCUtils.get_quest_givers(all_npcs)

print("Found %d quest givers" % quest_givers.size())
```

---

### has_available_quests()

Checks if NPC has available quests.

```gdscript
func has_available_quests(runtime_npc: PPRuntimeNPC, completed_quest_ids: Array) -> bool
```

**Note:** Emits `npc_has_quest_available` signal if quests are found.

**Example:**
```gdscript
var completed = PPQuestManager.get_completed_quest_ids()
if PPNPCUtils.has_available_quests(npc, completed):
    show_quest_indicator(npc)
```

---

### track_npc_interaction()

Tracks NPC interaction for quest objectives.

```gdscript
func track_npc_interaction(active_quests: Array, npc_entity: PPNPCEntity) -> void
```

**Example:**
```gdscript
func on_npc_dialogue_started(npc: PPNPCEntity):
    var active_quests = PPQuestManager.get_active_quests()
    PPNPCUtils.track_npc_interaction(active_quests, npc)
    # Updates any "Talk to NPC" objectives
```

---

### validate_quest_giver()

Validates that NPC can give a specific quest.

```gdscript
func validate_quest_giver(quest: PPQuestEntity, npc: PPNPCEntity) -> bool
```

**Example:**
```gdscript
if PPNPCUtils.validate_quest_giver(quest_entity, npc_entity):
    print("NPC can give this quest")
```

---

### can_start_quest_at_time()

Checks if quest can be started at current time.

```gdscript
func can_start_quest_at_time(
    quest: PPQuestEntity,
    npc: PPRuntimeNPC,
    current_hour: int
) -> bool
```

**Checks:**
- NPC is quest giver
- NPC is alive
- NPC is not hostile

**Example:**
```gdscript
var current_hour = 14  # 2 PM
if PPNPCUtils.can_start_quest_at_time(quest, npc, current_hour):
    offer_quest(quest)
```

---

## Filtering & Sorting

### filter_by_faction()

Filters NPCs by faction.

```gdscript
func filter_by_faction(npcs: Array, faction: String) -> Array
```

**Example:**
```gdscript
var guards = PPNPCUtils.filter_by_faction(all_npcs, "Town Guard")
var bandits = PPNPCUtils.filter_by_faction(all_npcs, "Bandits")
```

---

### get_alive_npcs()

Gets alive NPCs.

```gdscript
func get_alive_npcs(npcs: Array) -> Array
```

**Example:**
```gdscript
var alive = PPNPCUtils.get_alive_npcs(all_npcs)
print("%d alive NPCs" % alive.size())
```

---

### get_dead_npcs()

Gets dead NPCs.

```gdscript
func get_dead_npcs(npcs: Array) -> Array
```

---

### get_hostile_npcs()

Gets hostile NPCs.

```gdscript
func get_hostile_npcs(npcs: Array) -> Array
```

**Example:**
```gdscript
var enemies = PPNPCUtils.get_hostile_npcs(all_npcs)
for enemy in enemies:
    add_to_combat_list(enemy)
```

---

### 💎 get_friendly_npcs()

Gets NPCs with reputation >= 25 (Friendly or better).

**Premium Only**

```gdscript
func get_friendly_npcs(npcs: Array) -> Array
```

**Example:**
```gdscript
var friends = PPNPCUtils.get_friendly_npcs(all_npcs)
print("%d friendly NPCs" % friends.size())

for npc in friends:
    print("- %s (reputation: %d)" % [npc.get_npc_name(), npc.get_reputation()])
```

---

### 💎 get_all_merchants()

Gets all merchant NPCs.

**Premium Only**

```gdscript
func get_all_merchants(npcs: Array) -> Array
```

**Example:**
```gdscript
var merchants = PPNPCUtils.get_all_merchants(all_npcs)
print("Found %d merchants" % merchants.size())

for merchant in merchants:
    if merchant.is_alive():
        show_merchant_marker(merchant)
```

---

### sort_npcs()

Sorts NPCs by various criteria.

```gdscript
func sort_npcs(npcs: Array, sort_by: String) -> Array
```

**Sort options:**
- `"name"`: Alphabetical by name
- `"health"`: By current health (highest first)
- `"faction"`: By faction name
- 💎 `"reputation"`: By reputation (highest first) - **Premium Only**

**Example:**
```gdscript
var sorted = PPNPCUtils.sort_npcs(all_npcs, "health")
# NPCs with most health first

# 💎 Premium: Sort by reputation
var sorted_by_rep = PPNPCUtils.sort_npcs(all_npcs, "reputation")
# Most friendly NPCs first
```

---

## 💎 Reputation System

**Premium Only**

### modify_npc_reputation()

Modifies an NPC's reputation with the player.

```gdscript
func modify_npc_reputation(runtime_npc: PPRuntimeNPC, amount: int, reason: String = "") -> void
```

**Parameters:**
- `runtime_npc`: NPC whose reputation to modify
- `amount`: Amount to add/subtract (-100 to +100)
- `reason`: Optional reason for the change

**Emits:** `reputation_threshold_reached` when reputation level changes

**Example:**
```gdscript
# Player helped NPC
PPNPCUtils.modify_npc_reputation(npc, 10, "helped_with_quest")

# Player attacked NPC
PPNPCUtils.modify_npc_reputation(npc, -25, "attacked")

print("New reputation: %d (%s)" % [npc.get_reputation(), npc.get_reputation_level()])
```

---

### modify_faction_reputation()

Modifies reputation with an entire faction.

```gdscript
func modify_faction_reputation(npcs: Array, faction: String, amount: int) -> void
```

**Parameters:**
- `npcs`: Array of all NPCs
- `faction`: Faction ID to modify
- `amount`: Reputation change amount

**Emits:** `faction_reputation_changed` with average reputation

**Example:**
```gdscript
# Player helped kingdom
PPNPCUtils.modify_faction_reputation(all_npcs, "KINGDOM", 15)

# Player attacked bandits (increases guard reputation)
PPNPCUtils.modify_faction_reputation(all_npcs, "TOWN_GUARDS", 5)
```

---

### get_faction_reputation()

Gets average reputation with a faction.

```gdscript
func get_faction_reputation(npcs: Array, faction: String) -> float
```

**Returns:** Average reputation across all faction members

**Example:**
```gdscript
var avg_rep = PPNPCUtils.get_faction_reputation(all_npcs, "KINGDOM")
print("Kingdom reputation: %.1f" % avg_rep)
```

---

## 💎 Trading & Merchant System

**Premium Only**

### buy_from_merchant()

Player buys item from merchant NPC.

```gdscript
func buy_from_merchant(
    merchant: PPRuntimeNPC,
    player_inventory: PPInventory,
    item: PPItemEntity,
    quantity: int
) -> bool
```

**Parameters:**
- `merchant`: Merchant NPC
- `player_inventory`: Player's inventory
- `item`: Item to buy
- `quantity`: Number to buy

**Returns:** `true` if purchase succeeded

**Emits:** `merchant_transaction_completed` or `merchant_transaction_failed`

**Example:**
```gdscript
var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity

if PPNPCUtils.buy_from_merchant(merchant_npc, player.inventory, potion, 3):
    print("Bought 3 potions!")
else:
    print("Purchase failed (check currency/stock)")
```

---

### sell_to_merchant()

Player sells item to merchant NPC.

```gdscript
func sell_to_merchant(
    merchant: PPRuntimeNPC,
    player_inventory: PPInventory,
    item: PPItemEntity,
    quantity: int
) -> bool
```

**Returns:** `true` if sale succeeded

**Example:**
```gdscript
var old_sword = Pandora.get_entity("RUSTY_SWORD") as PPItemEntity

if PPNPCUtils.sell_to_merchant(merchant_npc, player.inventory, old_sword, 1):
    print("Sold rusty sword!")
```

---

### get_purchase_preview()

Gets detailed purchase information before buying.

```gdscript
func get_purchase_preview(
    merchant: PPRuntimeNPC,
    item: PPItemEntity,
    quantity: int,
    player_currency: int
) -> Dictionary
```

**Returns:** Dictionary with:
- `item`: PPItemEntity
- `quantity`: int
- `base_price`: float
- `price_per_unit`: float (with merchant markup)
- `total_price`: float (with reputation discount)
- `reputation_level`: String
- `reputation_discount`: float
- `can_afford`: bool
- `in_stock`: bool

**Example:**
```gdscript
var preview = PPNPCUtils.get_purchase_preview(
    merchant_npc,
    potion,
    3,
    player.inventory.game_currency
)

print("Total: %d gold" % preview["total_price"])
print("Reputation discount: %.0f%%" % (preview["reputation_discount"] * 100))
print("Can afford: %s" % preview["can_afford"])
```

---

### get_sell_preview()

Gets detailed sell information before selling.

```gdscript
func get_sell_preview(
    merchant: PPRuntimeNPC,
    item: PPItemEntity,
    quantity: int
) -> Dictionary
```

**Returns:** Dictionary with sell price details

**Example:**
```gdscript
var preview = PPNPCUtils.get_sell_preview(merchant_npc, sword, 1)
print("Sell for: %d gold" % preview["total_price"])
```

---

### find_merchants_with_item()

Finds all merchants selling a specific item.

```gdscript
func find_merchants_with_item(npcs: Array, item: PPItemEntity) -> Array
```

**Example:**
```gdscript
var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity
var sellers = PPNPCUtils.find_merchants_with_item(all_npcs, potion)

print("Found %d merchants selling %s" % [sellers.size(), potion.get_item_name()])
```

---

### update_merchant_restocks()

Updates merchant inventory restocks.

```gdscript
func update_merchant_restocks(merchants: Array, current_game_time: float) -> void
```

**Example:**
```gdscript
# Call periodically in game loop
func _on_hour_changed(new_hour: int):
    var merchants = PPNPCUtils.get_all_merchants(all_npcs)
    PPNPCUtils.update_merchant_restocks(merchants, Time.get_ticks_msec())
```

---

## 💎 Schedule Management

**Premium Only**

### update_all_schedules()

Updates all NPC schedules to current game time.

```gdscript
func update_all_schedules(npcs: Array, current_game_hour: int) -> void
```

**Parameters:**
- `npcs`: Array of all NPCs
- `current_game_hour`: Current hour (0-23)

**Emits:** `npc_schedule_updated` for each NPC

**Example:**
```gdscript
# Connect to time system
PPTimeManager.hour_changed.connect(_on_hour_changed)

func _on_hour_changed(new_hour: int):
    PPNPCUtils.update_all_schedules(all_npcs, new_hour)
    print("Updated schedules for hour %d" % new_hour)
```

---

### get_npcs_by_activity()

Gets all NPCs performing a specific activity.

```gdscript
func get_npcs_by_activity(npcs: Array, activity: String) -> Array
```

**Example:**
```gdscript
var sleeping = PPNPCUtils.get_npcs_by_activity(all_npcs, "sleep")
print("%d NPCs are sleeping" % sleeping.size())

var working = PPNPCUtils.get_npcs_by_activity(all_npcs, "work")
print("%d NPCs are working" % working.size())
```

---

### is_npc_available_at_time()

Checks if NPC will be at a location at a specific time.

```gdscript
func is_npc_available_at_time(
    npc: PPRuntimeNPC,
    hour: int,
    location: PandoraReference
) -> bool
```

**Example:**
```gdscript
var tavern = Pandora.get_reference("LOCATION_TAVERN")

if PPNPCUtils.is_npc_available_at_time(npc, 20, tavern):
    print("NPC will be at tavern at 8 PM")
```

---

### get_next_available_time()

Gets next hour when NPC will be at a location.

```gdscript
func get_next_available_time(
    npc: PPRuntimeNPC,
    location: PandoraReference,
    current_hour: int
) -> int
```

**Returns:** Hour (0-23) when NPC will be at location, or `-1` if never

**Example:**
```gdscript
var shop = Pandora.get_reference("LOCATION_SHOP")
var next_hour = PPNPCUtils.get_next_available_time(npc, shop, current_hour)

if next_hour >= 0:
    print("NPC will be at shop at %d:00" % next_hour)
else:
    print("NPC never visits this location")
```

---

### get_schedule_preview()

Gets 24-hour schedule preview for UI display.

```gdscript
func get_schedule_preview(npc: PPRuntimeNPC) -> Array
```

**Returns:** Array of dictionaries with `hour`, `location`, and `activity` keys

**Example:**
```gdscript
var schedule = PPNPCUtils.get_schedule_preview(npc)

for entry in schedule:
    print("%02d:00 - %s at %s" % [
        entry["hour"],
        entry["activity"],
        entry["location"].get_entity().get_string("name")
    ])
```

---

## Statistics & Analytics

### calculate_npc_stats()

Calculates NPC statistics.

```gdscript
func calculate_npc_stats(npcs: Array) -> Dictionary
```

**Returns:** Dictionary with keys:
- `total_npcs`: int
- `alive_count`: int
- `dead_count`: int
- `faction_distribution`: Dictionary (faction → count)
- `hostile_count`: int
- `quest_giver_count`: int
- 💎 `average_reputation`: float - **Premium Only**
- 💎 `merchant_count`: int - **Premium Only**

**Example:**
```gdscript
var stats = PPNPCUtils.calculate_npc_stats(all_npcs)

print("Total NPCs: %d" % stats["total_npcs"])
print("Alive: %d" % stats["alive_count"])
print("Quest Givers: %d" % stats["quest_giver_count"])

# 💎 Premium: Reputation and merchant stats
print("Average reputation: %.1f" % stats["average_reputation"])
print("Merchants: %d" % stats["merchant_count"])

for faction in stats["faction_distribution"]:
    print("  %s: %d" % [faction, stats["faction_distribution"][faction]])
```

---

### get_most_common_faction()

Gets the most common faction.

```gdscript
func get_most_common_faction(npcs: Array) -> String
```

**Example:**
```gdscript
var dominant = PPNPCUtils.get_most_common_faction(all_npcs)
print("Most common faction: ", dominant)
```

---

## Debug Utilities

### debug_print_npc()

Prints NPC debug info.

```gdscript
func debug_print_npc(runtime_npc: PPRuntimeNPC) -> void
```

**Example:**
```gdscript
PPNPCUtils.debug_print_npc(runtime_npc)
```

**Output:**
```
=== NPC Debug Info ===
Name: Village Elder
ID: npc_village_elder
Faction: Village
Alive: true
Health: 100/100
Hostile: false
Quest Giver: true
=====================
```

---

### debug_print_all_npcs()

Prints all NPCs.

```gdscript
func debug_print_all_npcs(npcs: Array) -> void
```

**Example:**
```gdscript
PPNPCUtils.debug_print_all_npcs(all_npcs)
```

**Output:**
```
=== All NPCs (5) ===
- Village Elder [Village] HP:100
- Guard Captain [Town Guard] HP:150
- Bandit [Bandits] HP:75
- Merchant [Neutral] HP:80
- Blacksmith [Village] HP:120
=========================
```

---

## Common Usage Patterns

### Pattern 1: Enemy Combat

```gdscript
class_name Enemy
extends CharacterBody3D

var runtime_npc: PPRuntimeNPC

func _ready():
    var npc_entity = Pandora.get_entity("npc_goblin") as PPNPCEntity
    runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

    # Ensure hostile
    runtime_npc.npc_data["is_hostile"] = true

func take_hit(damage: float):
    PPNPCUtils.damage_npc(runtime_npc, damage, "player")

    if not runtime_npc.is_alive():
        on_death()

func on_death():
    # Track for quests
    var active_quests = PPQuestManager.get_active_quests()
    for quest in active_quests:
        PPQuestUtils.track_enemy_killed(quest, runtime_npc._npc_entity)

    # Drop loot
    spawn_loot()
    queue_free()
```

---

### Pattern 2: Quest Giver NPC

```gdscript
func on_player_interact(npc: PPRuntimeNPC):
    # Can't interact with dead or hostile NPCs
    if not PPNPCUtils.can_interact_with_npc(npc):
        return

    # Check for quests
    var completed = PPQuestManager.get_completed_quest_ids()

    if PPNPCUtils.has_available_quests(npc, completed):
        var quests = PPNPCUtils.get_available_quests_from_npc(npc, completed)
        show_quest_selection_ui(quests)
    else:
        show_generic_dialogue(npc)
```

---

### Pattern 3: Faction-Based AI

```gdscript
func update_npc_relations():
    var player_faction = player.get_faction()
    var all_npcs = get_all_spawned_npcs()

    for npc in all_npcs:
        var npc_faction = npc.npc_data.get("faction", "Neutral")

        if are_factions_hostile(player_faction, npc_faction):
            npc.npc_data["is_hostile"] = true
        else:
            npc.npc_data["is_hostile"] = false
```

---

### Pattern 4: Location-Based Events

```gdscript
func trigger_ambush():
    var all_npcs = get_all_spawned_npcs()
    var forest_ref = PandoraReference.new("dark_forest", PandoraReference.Type.ENTITY)
    var npcs_in_forest = PPNPCUtils.get_npcs_at_location(all_npcs, forest_ref)

    # Make all bandits in forest hostile
    for npc in npcs_in_forest:
        if npc.npc_data.get("faction") == "Bandits":
            npc.npc_data["is_hostile"] = true
            start_combat(npc)
```

---

## See Also

- [NPC System](../core-systems/npc-system.md) - NPC system overview
- [PPRuntimeNPC](../api/runtime-npc.md) - Runtime NPC API
- [Quest System](../core-systems/quest-system.md) - Quest integration

---

*API Reference for Pandora+ v1.0.0*
