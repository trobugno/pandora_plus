# Create Your First RPG with Pandora+

A step-by-step tutorial to build a complete mini-RPG with quests, NPCs, inventory, and combat.

**Difficulty:** Beginner
**Time:** ~45 minutes
**Prerequisites:** Godot 4.x, Pandora+ installed

---

## What You'll Build

By the end of this tutorial, you'll have created:

- ✅ A playable character with stats and inventory
- ✅ NPCs that give quests
- ✅ A quest system with objectives and rewards
- ✅ An inventory system with items
- ✅ Basic combat with stat modifiers
- ✅ Save/load functionality

---

## Part 1: Project Setup

### Step 1: Create New Project

1. Open Godot 4.x
2. Create new project: "MyFirstRPG"
3. Install Pandora+ (if not already installed)

### Step 2: Configure Autoloads

Add Pandora+ autoloads to Project Settings:

```
Project -> Project Settings -> Autoload
```

Add these autoloads:

| Name | Path | Enabled |
|------|------|---------|
| Pandora | res://addons/pandora/Pandora.gd | ✅ |
| PPQuestManager | res://addons/pandora_plus/autoloads/PPQuestManager.gd | ✅ |
| PPPlayerManager | res://addons/pandora_plus/autoloads/PPPlayerManager.gd | ✅ |
| PPQuestUtils | res://addons/pandora_plus/autoloads/PPQuestUtils.gd | ✅ |
| PPNPCUtils | res://addons/pandora_plus/autoloads/PPNPCUtils.gd | ✅ |
| InventoryUtils | res://addons/pandora_plus/autoloads/PPInventoryUtils.gd | ✅ |

### Step 3: Create Folder Structure

```
res://
├── entities/          # Pandora entities
├── scenes/
│   ├── game_world.tscn
│   ├── player.tscn
│   └── ui/
│       ├── quest_ui.tscn
│       └── inventory_ui.tscn
└── scripts/
    └── player.gd
```

---

## Part 2: Creating Entities in Pandora

### Step 1: Open Pandora Editor

1. Click "Pandora" tab at the top of Godot editor
2. Create new database: "game_data.tres"

### Step 2: Create Item Entities

Create a health potion:

1. Click "New Entity"
2. Set category: "Item"
3. Entity ID: `HEALTH_POTION`
4. Add properties:
   - `name` (String): "Health Potion"
   - `description` (String): "Restores 50 HP"
   - `value` (float): 25.0
   - `weight` (float): 0.5
   - `stackable` (bool): true

Create a sword:

1. New Entity → Category: "Equipment"
2. Entity ID: `IRON_SWORD`
3. Properties:
   - `name` (String): "Iron Sword"
   - `description` (String): "A sturdy iron blade"
   - `equipment_slot` (String): "WEAPON"
   - `value` (float): 100.0
   - `weight` (float): 5.0
   - `stackable` (bool): false
   - `stats_property` (PPStats):
     - Health: 0
     - Attack: 10
     - Defense: 0

### Step 3: Create NPC Entity

Create a village elder:

1. New Entity → Category: "NPC"
2. Entity ID: `VILLAGE_ELDER`
3. Properties:
   - `npc_name` (String): "Village Elder"
   - `faction` (String): "Villagers"
   - `is_hostile` (bool): false
   - `max_health` (float): 100.0

### Step 4: Create Quest Entity

Create your first quest:

1. New Entity → Category: "Quest"
2. Entity ID: `QUEST_WELCOME`
3. Add property: `quest_data` (PPQuest)

Click on `quest_data` to configure:

**Quest Info:**
- Quest ID: "welcome_quest"
- Quest Name: "Welcome to the Village"
- Description: "The village elder wants to meet you"
- Quest Type: MAIN_STORY
- Auto Complete: true

**Quest Giver:**
- Select VILLAGE_ELDER entity reference

**Objectives:**
Add objective:
- ID: "talk_to_elder"
- Type: TALK
- Description: "Talk to the Village Elder"
- Target: VILLAGE_ELDER reference
- Target Quantity: 1
- Hidden: false

**Rewards:**
Add reward:
- Name: "Welcome Gift"
- Type: ITEM
- Item: HEALTH_POTION reference
- Quantity: 3

---

## Part 3: Creating the Player

### Step 1: Player Scene

Create `res://scenes/player.tscn`:

```
CharacterBody2D (name: Player)
├── Sprite2D (icon or character sprite)
├── CollisionShape2D
└── Camera2D
```

### Step 2: Player Script

Create `res://scripts/player.gd`:

```gdscript
extends CharacterBody2D

const SPEED = 200.0

# Player data
var player_data: PPPlayerData
var inventory: PPInventory
var runtime_stats: PPRuntimeStats

# UI references (set in _ready)
var quest_ui
var inventory_ui

func _ready():
    # Initialize player data
    player_data = PPPlayerData.new()
    player_data.set_player_name("Hero")

    # Initialize inventory (20 slots, 8 equipment slots)
    inventory = PPInventory.new(20, 8)
    inventory.game_currency = 100  # Starting gold

    # Initialize stats
    var base_stats = {
        "health": 100.0,
        "mana": 50.0,
        "attack": 5.0,
        "defense": 3.0
    }
    runtime_stats = PPRuntimeStats.new(base_stats)

    # Give starting items
    give_starting_items()

    # Find UI nodes
    quest_ui = get_tree().get_first_node_in_group("quest_ui")
    inventory_ui = get_tree().get_first_node_in_group("inventory_ui")

    # Update UI
    if quest_ui:
        quest_ui.player = self
    if inventory_ui:
        inventory_ui.player = self

func give_starting_items():
    # Give starting potion
    var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity
    inventory.add_item(potion, 1)

    # Give starting weapon
    var sword = Pandora.get_entity("IRON_SWORD") as PPEquipmentEntity
    inventory.add_item(sword, 1)

func _physics_process(delta):
    # Simple movement
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = direction * SPEED
    move_and_slide()

    # Open/close inventory
    if Input.is_action_just_pressed("ui_cancel"):  # ESC key
        if inventory_ui:
            inventory_ui.toggle()

func interact_with_npc(npc_entity: PPNPCEntity):
    # Create runtime NPC
    var runtime_npc = PPRuntimeNPC.new(npc_entity)

    # Check for available quests
    var completed_ids = PPQuestManager.get_completed_quest_ids()
    var available_quests = runtime_npc.get_available_quests(1, completed_ids)

    if available_quests.size() > 0:
        # Show quest dialog
        if quest_ui:
            quest_ui.show_quest_dialog(runtime_npc, available_quests)
    else:
        # Show generic dialog
        show_dialog("Hello, traveler!")

func show_dialog(text: String):
    print("NPC says: ", text)
    # TODO: Show dialog UI
```

---

## Part 4: Creating NPCs in the World

### NPC Scene

Create `res://scenes/npc.tscn`:

```
Area2D (name: NPC)
├── Sprite2D (NPC sprite)
├── CollisionShape2D
└── Label (NPC name)
```

### NPC Script

```gdscript
extends Area2D

@export var npc_entity_id: String = "VILLAGE_ELDER"
var npc_entity: PPNPCEntity

func _ready():
    # Load NPC entity
    npc_entity = Pandora.get_entity(npc_entity_id) as PPNPCEntity

    if npc_entity:
        $Label.text = npc_entity.get_npc_name()

    # Connect interaction
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if body.name == "Player":
        body.interact_with_npc(npc_entity)
```

---

## Part 5: Quest UI

### Quest UI Scene

Create `res://scenes/ui/quest_ui.tscn`:

```
CanvasLayer (name: QuestUI, groups: ["quest_ui"])
└── Panel
    ├── Label (title)
    ├── RichTextLabel (description)
    ├── VBoxContainer (objectives_list)
    ├── VBoxContainer (rewards_list)
    └── HBoxContainer
        ├── Button (accept_button)
        └── Button (decline_button)
```

### Quest UI Script

```gdscript
extends CanvasLayer

var player
var current_quest_entity: PPQuestEntity
var current_npc: PPRuntimeNPC

@onready var panel = $Panel
@onready var title_label = $Panel/Label
@onready var description_label = $Panel/RichTextLabel
@onready var objectives_list = $Panel/ObjectivesList
@onready var rewards_list = $Panel/RewardsList
@onready var accept_button = $Panel/HBoxContainer/AcceptButton
@onready var decline_button = $Panel/HBoxContainer/DeclineButton

func _ready():
    panel.hide()
    accept_button.pressed.connect(_on_accept_pressed)
    decline_button.pressed.connect(_on_decline_pressed)

func show_quest_dialog(npc: PPRuntimeNPC, quests: Array):
    if quests.is_empty():
        return

    current_npc = npc
    current_quest_entity = quests[0]  # Show first quest

    var quest_data = current_quest_entity.get_quest_data()

    # Update UI
    title_label.text = quest_data.get_quest_name()
    description_label.text = quest_data.get_description()

    # Show objectives
    clear_list(objectives_list)
    for objective in quest_data.get_objectives():
        if not objective.is_hidden():
            var label = Label.new()
            label.text = "• " + objective.get_description()
            objectives_list.add_child(label)

    # Show rewards
    clear_list(rewards_list)
    for reward in quest_data.get_rewards():
        var label = Label.new()
        match reward.get_reward_type():
            PPQuestReward.RewardType.ITEM:
                var item = reward.get_reward_entity()
                label.text = "• %d x %s" % [reward.get_quantity(), item.get_item_name()]
            PPQuestReward.RewardType.CURRENCY:
                label.text = "• %d Gold" % reward.get_currency_amount()
            PPQuestReward.RewardType.EXPERIENCE:
                label.text = "• %d XP" % reward.get_experience_amount()
        rewards_list.add_child(label)

    panel.show()

func _on_accept_pressed():
    if not current_quest_entity:
        return

    # Start quest
    var quest_data = current_quest_entity.get_quest_data()
    var runtime_quest = PPQuestUtils.start_quest_from_data(quest_data, 1, [])

    if runtime_quest:
        PPQuestManager.add_quest(runtime_quest)
        print("Quest started: ", quest_data.get_quest_name())

    panel.hide()

func _on_decline_pressed():
    panel.hide()

func clear_list(container: VBoxContainer):
    for child in container.get_children():
        child.queue_free()
```

---

## Part 6: Inventory UI

### Inventory UI Scene

Create `res://scenes/ui/inventory_ui.tscn`:

```
CanvasLayer (name: InventoryUI, groups: ["inventory_ui"])
└── Panel
    ├── Label ("Inventory")
    ├── GridContainer (inventory_grid)
    ├── HBoxContainer
    │   └── Label (currency_label)
    └── Button (close_button)
```

### Inventory UI Script

```gdscript
extends CanvasLayer

var player

@onready var panel = $Panel
@onready var inventory_grid = $Panel/InventoryGrid
@onready var currency_label = $Panel/HBoxContainer/CurrencyLabel
@onready var close_button = $Panel/CloseButton

func _ready():
    panel.hide()
    close_button.pressed.connect(_on_close_pressed)

    # Configure grid
    inventory_grid.columns = 5

func toggle():
    if panel.visible:
        panel.hide()
    else:
        show_inventory()

func show_inventory():
    if not player:
        return

    # Clear grid
    for child in inventory_grid.get_children():
        child.queue_free()

    # Add inventory slots
    for i in range(player.inventory.max_items_in_inventory):
        var slot_button = create_slot_button(i)
        inventory_grid.add_child(slot_button)

    # Update currency
    currency_label.text = "Gold: %d" % player.inventory.game_currency

    panel.show()

func create_slot_button(index: int) -> Button:
    var button = Button.new()
    button.custom_minimum_size = Vector2(64, 64)

    # Get item in slot
    var inventory = player.inventory
    if index < inventory.all_items.size():
        var slot = inventory.all_items[index]
        if slot and slot.item:
            var item = slot.item
            button.text = "%s\nx%d" % [item.get_item_name(), slot.quantity]
            button.pressed.connect(_on_item_clicked.bind(item))

    return button

func _on_item_clicked(item):
    # TODO: Show item details
    # TODO: Use/equip item
    print("Clicked item: ", item.get_item_name())

func _on_close_pressed():
    panel.hide()
```

---

## Part 7: Game World

### Create Game World Scene

Create `res://scenes/game_world.tscn`:

```
Node2D (name: GameWorld)
├── TileMap (optional: ground tiles)
├── Player (instance of player.tscn)
├── NPC (instance of npc.tscn, position at (200, 200))
├── QuestUI (instance of quest_ui.tscn)
└── InventoryUI (instance of inventory_ui.tscn)
```

Set as main scene in Project Settings.

---

## Part 8: Testing Your RPG

### Run the Game

1. Press F5 to run
2. Move your character with arrow keys
3. Walk near the NPC to interact
4. Accept the quest
5. Press ESC to open inventory
6. Complete the quest objective (talk to elder)

### Quest Completion

To complete the quest, add quest tracking:

Update player script to track quest completion:

```gdscript
func interact_with_npc(npc_entity: PPNPCEntity):
    var runtime_npc = PPRuntimeNPC.new(npc_entity)

    # Track quest objectives
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_npc_talked(quest, npc_entity)

    # Check for quests
    var completed_ids = PPQuestManager.get_completed_quest_ids()
    var available_quests = runtime_npc.get_available_quests(1, completed_ids)

    if available_quests.size() > 0:
        if quest_ui:
            quest_ui.show_quest_dialog(runtime_npc, available_quests)
```

---

## Part 9: Adding Save/Load

### Save System

Create `res://scripts/save_system.gd`:

```gdscript
extends Node

const SAVE_PATH = "user://savegame.dat"

func save_game(player):
    var save_data = {
        "player_name": player.player_data.get_player_name(),
        "inventory": player.inventory.to_dict(),
        "runtime_stats": player.runtime_stats.to_dict(),
        "position": {
            "x": player.global_position.x,
            "y": player.global_position.y
        },
        "completed_quests": PPQuestManager.get_completed_quest_ids(),
        "active_quests": []
    }

    # Save active quests
    for quest in PPQuestManager.get_active_quests():
        save_data["active_quests"].append(quest.to_dict())

    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_var(save_data)
    file.close()

    print("Game saved!")

func load_game(player):
    if not FileAccess.file_exists(SAVE_PATH):
        print("No save file found")
        return false

    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    var save_data = file.get_var()
    file.close()

    # Restore player data
    player.player_data.set_player_name(save_data["player_name"])
    player.inventory = PPInventory.from_dict(save_data["inventory"])
    player.runtime_stats = PPRuntimeStats.from_dict(save_data["runtime_stats"])
    player.global_position = Vector2(save_data["position"]["x"], save_data["position"]["y"])

    # Restore quests
    PPQuestManager.clear_all()

    for quest_data in save_data["active_quests"]:
        var runtime_quest = PPRuntimeQuest.from_dict(quest_data)
        PPQuestManager.add_quest(runtime_quest)

    print("Game loaded!")
    return true
```

Add to player script:

```gdscript
func _input(event):
    if event.is_action_pressed("ui_save"):  # F5
        SaveSystem.save_game(self)
    elif event.is_action_pressed("ui_load"):  # F9
        SaveSystem.load_game(self)
```

---

## Part 10: Next Steps

Congratulations! You've created your first RPG with Pandora+! 🎉

### What You've Learned

- ✅ Setting up Pandora+ in a project
- ✅ Creating entities (Items, NPCs, Quests)
- ✅ Building a player with inventory and stats
- ✅ Implementing quest system
- ✅ Creating interactive NPCs
- ✅ Building UI for quests and inventory
- ✅ Save/load system

### Expand Your RPG

Now try adding:

1. **More Quests** - Create quest chains with prerequisites
2. **Combat System** - Use PPCombatCalculator for enemies
3. **Equipment** - Let players equip weapons and armor
4. **Shops** - Create merchant NPCs
5. **Crafting** - Add recipe system
6. **Dialogue** - Expand NPC interactions

### Additional Tutorials

- [Building a Quest System](building-quest.md) - Advanced quest mechanics
- [Building an Inventory UI](building-inventory-ui.md) - Professional inventory system
- [NPC Routine (Premium)](npc-routine.md) - NPC schedules and behaviors

---

## Troubleshooting

### Quest not starting?
- Check that quest entity ID matches
- Verify quest_data property is configured
- Check autoload PPQuestManager is enabled

### NPC not interacting?
- Ensure NPC entity_id is correct
- Check Area2D collision shape
- Verify player has collision layer/mask set

### Items not showing in inventory?
- Check that items have correct entity IDs
- Verify inventory max_items is set
- Check item stackable property

---

## Full Project Files

Download complete project: [MyFirstRPG.zip](#)

---

*Tutorial for Pandora+ v1.0.0*
