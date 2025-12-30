# Quest System

Complete guide to the Pandora+ Quest System - a full-featured quest management solution for building quest-based RPG games.

---

## Overview

The Pandora+ Quest System provides comprehensive quest management with objectives, rewards, prerequisites, and state tracking. It's designed to handle everything from simple fetch quests to complex multi-stage quest chains.

**Core Components:**
- **PPQuest** - Quest data model with objectives and rewards
- **PPRuntimeQuest** - Active quest instance with progress tracking
- **PPQuestEntity** - Pandora entity wrapper for quests
- **PPQuestManager** - Centralized quest lifecycle management
- **PPQuestUtils** - Utility functions for quest operations

---

## Quick Start

### Basic Quest Setup

```gdscript
# Create quest data
var quest = PPQuest.new()
quest.set_quest_id("village_rescue")
quest.set_quest_name("Village in Danger")
quest.set_description("Help the village by defeating 5 goblins and collecting 3 healing herbs.")

# Add objectives
var kill_objective = PPQuestObjective.create_kill("goblin", 5)
var collect_objective = PPQuestObjective.create_collect("healing_herb", 3)
quest.add_objective(kill_objective)
quest.add_objective(collect_objective)

# Add rewards
var exp_reward = PPQuestReward.create_experience(100)
var gold_reward = PPQuestReward.create_currency(50)
quest.add_reward(exp_reward)
quest.add_reward(gold_reward)

# Create quest entity
var quest_entity = PPQuestEntity.new()
quest_entity.set_entity_id("village_rescue")
quest_entity.set_quest_data(quest)

# Start quest
var runtime_quest = PPQuestManager.start_quest(quest_entity)
```

### Tracking Quest Progress

```gdscript
# Track enemy kills
PPQuestUtils.track_enemy_killed(runtime_quest, "goblin")

# Track item collection
var herb_item = Pandora.get_entity("healing_herb") as PPItemEntity
PPQuestUtils.track_item_collected(runtime_quest, herb_item, 1)

# Check if quest auto-completed
if runtime_quest.get_status() == PPRuntimeQuest.QuestStatus.COMPLETED:
    print("Quest completed!")
    apply_quest_rewards(runtime_quest)
```

---

## Architecture

### Component Relationships

```
PPQuestManager (Autoload)
├── Active Quests: Array[PPRuntimeQuest]
├── Completed Quest IDs: Array[String]
└── Failed Quest IDs: Array[String]

PPRuntimeQuest (Runtime Instance)
├── Quest Data: PPQuest
├── Objectives Progress: Array[Dictionary]
├── Status: QuestStatus enum
└── Timestamps: started_at, completed_at

PPQuest (Data Model)
├── Quest Info: id, name, description
├── Objectives: Array[PPQuestObjective]
├── Rewards: Array[PPQuestReward]
└── Prerequisites: Array[String]

PPQuestUtils (Autoload)
└── Quest operations and tracking
```

---

## Quest Components

### 1. Quest Data (PPQuest)

The core quest data structure:

```gdscript
var quest = PPQuest.new()

# Basic info
quest.set_quest_id("unique_quest_id")
quest.set_quest_name("The Quest Title")
quest.set_description("What the player needs to do")
quest.set_quest_type(0)  # Custom type index
quest.set_category("Main Quest")

# Quest giver
var npc_ref = PandoraReference.new("npc_elder", PandoraReference.Type.ENTITY)
quest.set_quest_giver(npc_ref)

# Prerequisites
quest.add_prerequisite("previous_quest_id")
```

### 2. Quest Objectives

Five objective types are supported:

#### Kill Objective
```gdscript
var obj = PPQuestObjective.create_kill("goblin", 5)
# Player must kill 5 entities with id "goblin"
```

#### Collect Objective
```gdscript
var obj = PPQuestObjective.create_collect("healing_herb", 3)
# Player must collect 3 items with id "healing_herb"
```

#### Talk To Objective
```gdscript
var obj = PPQuestObjective.create_talk("npc_blacksmith")
# Player must talk to NPC with id "npc_blacksmith"
```

#### Go To Objective
```gdscript
var obj = PPQuestObjective.create_goto("ancient_ruins")
# Player must reach location with id "ancient_ruins"
```

#### Custom Objective
```gdscript
var obj = PPQuestObjective.create_custom("find_secret", 1)
# Custom objective tracked manually
```

### 3. Quest Rewards

Three reward types are supported:

#### Experience Reward
```gdscript
var reward = PPQuestReward.create_experience(100)
# Awards 100 experience points
```

#### Currency Reward
```gdscript
var reward = PPQuestReward.create_currency(50)
# Awards 50 gold/currency
```

#### Item Reward
```gdscript
var item_ref = PandoraReference.new("magic_sword", PandoraReference.Type.ENTITY)
var reward = PPQuestReward.create_item(item_ref, 1)
# Awards 1 magic sword
```

---

## Quest Lifecycle

### Starting Quests

```gdscript
# From quest entity
var quest_entity = Pandora.get_entity("quest_id") as PPQuestEntity
var runtime_quest = PPQuestManager.start_quest(quest_entity)

# From quest data directly
var quest_data = PPQuest.new()
# ... configure quest ...
var runtime_quest = PPQuestManager.start_quest_from_data(quest_data)

# Validation happens automatically
# - Checks prerequisites are met
# - Checks quest not already completed
# - Checks quest not already active
```

### Quest States

```gdscript
# Quest states
PPRuntimeQuest.QuestStatus.ACTIVE      # Quest in progress
PPRuntimeQuest.QuestStatus.COMPLETED   # Successfully finished
PPRuntimeQuest.QuestStatus.FAILED      # Failed (manual)
PPRuntimeQuest.QuestStatus.ABANDONED   # Player gave up

# Check quest status
if runtime_quest.get_status() == PPRuntimeQuest.QuestStatus.ACTIVE:
    print("Quest is active")

# Get status as string
print(runtime_quest.get_status_string())  # "Active", "Completed", etc.
```

### Completing Quests

```gdscript
# Manual completion
PPQuestManager.complete_quest("quest_id")

# Auto-completion (when all objectives met)
# Happens automatically when tracking objectives
PPQuestUtils.track_enemy_killed(runtime_quest, "goblin")
# If this was the last objective, quest auto-completes

# Check completion
if runtime_quest.is_completed():
    apply_rewards(runtime_quest)
```

### Failing Quests

```gdscript
# Manual fail
PPQuestManager.fail_quest("quest_id")

# Quest becomes failed
```

### Abandoning Quests

```gdscript
# Player abandons quest
PPQuestManager.abandon_quest("quest_id")

# Quest is removed from active quests
# Can be restarted later if quest giver allows
```

---

## Tracking Progress

### Track Enemy Kills

```gdscript
# When player defeats an enemy
func on_enemy_defeated(enemy_id: String):
    # Track in all active quests
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_enemy_killed(quest, enemy_id)
```

### Track Item Collection

```gdscript
# When player collects item
func on_item_collected(item: PPItemEntity, quantity: int):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_item_collected(quest, item, quantity)
```

### Track NPC Interaction

```gdscript
# When player talks to NPC
func on_npc_talked(npc: PPNPCEntity):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_npc_talked(quest, npc)
```

### Track Location Reached

```gdscript
# When player enters location
func on_location_entered(location: PandoraEntity):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_location_reached(quest, location)
```

### Track Custom Objectives

```gdscript
# For custom objectives
func on_secret_found():
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_custom_objective(quest, "find_secret", 1)
```

---

## Quest Progress

### Check Progress

```gdscript
# Get overall progress percentage
var progress = runtime_quest.get_progress_percentage()
print("Quest is %.0f%% complete" % progress)

# Check individual objectives
var objectives = runtime_quest.get_objectives_progress()
for obj in objectives:
    print("%s: %d/%d" % [obj["type"], obj["current"], obj["required"]])

# Check if specific objective complete
if runtime_quest.is_objective_complete(0):
    print("First objective complete!")
```

### Quest Info Display

```gdscript
# For UI display
print(runtime_quest.get_quest_name())
print(runtime_quest.get_description())

# Get formatted objective list
var objectives_text = ""
for obj in runtime_quest.get_objectives_progress():
    var status = "✓" if obj["completed"] else "○"
    objectives_text += "%s %s (%d/%d)\n" % [
        status,
        obj["description"],
        obj["current"],
        obj["required"]
    ]
```

---

## Quest Chains & Prerequisites

### Setting Prerequisites

```gdscript
var quest = PPQuest.new()
quest.set_quest_id("advanced_quest")

# Require previous quests to be completed
quest.add_prerequisite("beginner_quest_1")
quest.add_prerequisite("beginner_quest_2")

# Quest can only start if both prerequisites are completed
```

### Checking Prerequisites

```gdscript
# Automatic validation during start_quest()
var runtime_quest = PPQuestManager.start_quest(quest_entity)
if not runtime_quest:
    print("Cannot start quest - prerequisites not met")

# Manual check
var completed_ids = PPQuestManager.get_completed_quest_ids()
if PPQuestUtils.can_start_quest(quest_data, completed_ids):
    print("Can start this quest")
```

---

## Quest Givers (NPCs)

### Assigning Quest Givers

```gdscript
# In quest data
var npc_ref = PandoraReference.new("npc_village_elder", PandoraReference.Type.ENTITY)
quest.set_quest_giver(npc_ref)

# Get quest giver entity
var giver = quest.get_quest_giver_entity()
if giver:
    print("Quest given by: ", giver.get_entity_id())
```

### Getting Available Quests from NPC

```gdscript
# Get available quests from an NPC
var npc_entity = Pandora.get_entity("npc_village_elder") as PPNPCEntity
var runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

var completed_ids = PPQuestManager.get_completed_quest_ids()
var available_quests = runtime_npc.get_available_quests(completed_ids)

for quest_entity in available_quests:
    print("Available: ", quest_entity.get_quest_data().get_quest_name())
```

---

## Save & Load

### Saving Quest State

```gdscript
# Quest Manager integrates with PPGameState
var game_state = PPGameState.new()
PPQuestManager.save_state(game_state)

# Game state contains:
# - Active quests (with progress)
# - Completed quest IDs
# - Failed quest IDs
```

### Loading Quest State

```gdscript
# Load from saved game state
var game_state = load_game_state_from_file()
PPQuestManager.load_state(game_state)

# All quests restored with progress
print("Loaded %d active quests" % PPQuestManager.get_active_quest_count())
```

### Manual Serialization

```gdscript
# Serialize individual quest
var quest_dict = runtime_quest.to_dict()
save_to_file(quest_dict)

# Deserialize
var loaded_dict = load_from_file()
var restored_quest = PPRuntimeQuest.from_dict(loaded_dict)
```

---

## Signals & Events

### Quest Manager Signals

```gdscript
# Connect to quest events
PPQuestManager.quest_added.connect(_on_quest_added)
PPQuestManager.quest_completed.connect(_on_quest_completed)
PPQuestManager.quest_failed.connect(_on_quest_failed)
PPQuestManager.quest_abandoned.connect(_on_quest_abandoned)

func _on_quest_added(runtime_quest: PPRuntimeQuest):
    print("New quest: ", runtime_quest.get_quest_name())

func _on_quest_completed(quest_id: String):
    print("Quest completed: ", quest_id)
    show_completion_ui(quest_id)
```

### Runtime Quest Signals

```gdscript
# Connect to individual quest
runtime_quest.objective_completed.connect(_on_objective_done)
runtime_quest.quest_completed.connect(_on_quest_done)

func _on_objective_done(index: int):
    print("Objective %d complete!" % index)
    show_objective_notification(index)
```

### Quest Utils Signals

```gdscript
# Validation events
PPQuestUtils.quest_validation_failed.connect(_on_validation_failed)

func _on_validation_failed(quest_id: String, reason: String):
    print("Cannot start quest %s: %s" % [quest_id, reason])
```

---

## Common Patterns

### Pattern 1: Quest Log UI

```gdscript
class_name QuestLogUI
extends Control

@onready var quest_list = $QuestList

func _ready():
    PPQuestManager.quest_added.connect(refresh)
    PPQuestManager.quest_removed.connect(refresh)
    refresh()

func refresh():
    # Clear list
    for child in quest_list.get_children():
        child.queue_free()

    # Show active quests
    for quest in PPQuestManager.get_active_quests():
        var entry = create_quest_entry(quest)
        quest_list.add_child(entry)

func create_quest_entry(quest: PPRuntimeQuest) -> Control:
    var entry = VBoxContainer.new()

    # Title
    var title = Label.new()
    title.text = quest.get_quest_name()
    entry.add_child(title)

    # Progress
    var progress = ProgressBar.new()
    progress.value = quest.get_progress_percentage()
    entry.add_child(progress)

    # Objectives
    for obj in quest.get_objectives_progress():
        var obj_label = Label.new()
        obj_label.text = "  %s %d/%d" % [
            obj["description"],
            obj["current"],
            obj["required"]
        ]
        entry.add_child(obj_label)

    return entry
```

### Pattern 2: Quest Tracker HUD

```gdscript
class_name QuestTrackerHUD
extends MarginContainer

@onready var tracker_list = $VBoxContainer

var tracked_quests: Array[PPRuntimeQuest] = []

func track_quest(quest: PPRuntimeQuest):
    if quest not in tracked_quests:
        tracked_quests.append(quest)
        quest.objective_completed.connect(refresh)
        refresh()

func refresh():
    for child in tracker_list.get_children():
        child.queue_free()

    for quest in tracked_quests:
        if quest.is_active():
            var tracker = create_tracker(quest)
            tracker_list.add_child(tracker)

func create_tracker(quest: PPRuntimeQuest) -> Control:
    var panel = PanelContainer.new()
    var vbox = VBoxContainer.new()
    panel.add_child(vbox)

    # Quest name
    var name_label = Label.new()
    name_label.text = quest.get_quest_name()
    vbox.add_child(name_label)

    # Show incomplete objectives only
    for obj in quest.get_objectives_progress():
        if not obj["completed"]:
            var obj_label = Label.new()
            obj_label.text = "○ %d/%d" % [obj["current"], obj["required"]]
            vbox.add_child(obj_label)

    return panel
```

### Pattern 3: Quest Giver NPC

```gdscript
class_name QuestGiverNPC
extends Node3D

@export var npc_entity_id: String

func on_player_interact():
    var npc_entity = Pandora.get_entity(npc_entity_id) as PPNPCEntity
    var runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

    # Get available quests
    var completed = PPQuestManager.get_completed_quest_ids()
    var quests = runtime_npc.get_available_quests(completed)

    if quests.is_empty():
        show_dialogue("I have no quests for you right now.")
    else:
        show_quest_selection_ui(quests)

func show_quest_selection_UI(available_quests: Array):
    # Show UI with quest list
    for quest_entity in available_quests:
        var quest_data = quest_entity.get_quest_data()
        # Display quest info and "Accept" button
```

---

## Best Practices

### ✅ Use Quest IDs Consistently

```gdscript
# ✅ Good: use constants
const QuestIDs = {
    VILLAGE_RESCUE = "village_rescue",
    DRAGON_SLAYER = "dragon_slayer"
}

quest.set_quest_id(QuestIDs.VILLAGE_RESCUE)

# ❌ Bad: magic strings everywhere
quest.set_quest_id("village_rescue")  # Typo-prone
```

### ✅ Track Progress for All Active Quests

```gdscript
# ✅ Good: track for all quests
func on_enemy_killed(enemy_id: String):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_enemy_killed(quest, enemy_id)

# ❌ Bad: only track for specific quest
PPQuestUtils.track_enemy_killed(current_quest, enemy_id)
```

### ✅ Use Signals for UI Updates

```gdscript
# ✅ Good: reactive UI
PPQuestManager.quest_added.connect(refresh_quest_log)

# ❌ Bad: polling
func _process(_delta):
    if quest_count_changed():
        refresh_quest_log()
```

---

## Troubleshooting

### Quest Won't Start

**Causes:**
- Prerequisites not met
- Quest already completed
- Quest already active

**Solution:**
```gdscript
var completed = PPQuestManager.get_completed_quest_ids()
if not PPQuestUtils.can_start_quest(quest_data, completed):
    print("Cannot start - check prerequisites")
```

### Objectives Not Tracking

**Cause:** Not calling track functions

**Solution:**
```gdscript
# Make sure you call tracking functions
PPQuestUtils.track_enemy_killed(quest, enemy_id)
PPQuestUtils.track_item_collected(quest, item, quantity)
```

### Quest Not Auto-Completing

**Cause:** Not all objectives met

**Solution:**
```gdscript
# Check progress
var progress = runtime_quest.get_objectives_progress()
for obj in progress:
    if not obj["completed"]:
        print("Incomplete: %s (%d/%d)" % [
            obj["description"],
            obj["current"],
            obj["required"]
        ])
```

---

## See Also

- [PPQuestUtils](../utilities/quest-utils.md) - Quest utility functions
- [PPRuntimeQuest](../api/runtime-quest.md) - Runtime quest API
- [PPQuest](../api/quest.md) - Quest data model
- [NPC System](npc-system.md) - Quest giver integration
- [Player Data](player-data.md) - Save/load integration

---

*Complete System Guide for Pandora+ v1.0.0*
