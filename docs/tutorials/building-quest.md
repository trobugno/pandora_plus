# Building a Quest System

A comprehensive tutorial on creating an advanced quest system with multiple objective types, quest chains, and dynamic rewards.

**Difficulty:** Intermediate
**Time:** ~60 minutes
**Prerequisites:** [Create Your First RPG](first-rpg.md) tutorial completed

---

## What You'll Build

An advanced quest system with:

- ✅ Multiple objective types (KILL, COLLECT, TALK, REACH_LOCATION)
- ✅ Quest chains with prerequisites
- ✅ Dynamic quest rewards
- ✅ Quest tracking UI with progress bars
- ✅ Quest log/journal
- ✅ Quest markers and indicators
- ✅ Quest categories and filtering

---

## Part 1: Advanced Quest Structure

### Quest Categories

Organize quests by type for better player experience.

Create quest entities with categories:

**Main Story Quest:**
```
Entity ID: QUEST_MAIN_001
Quest Data:
  - Quest Name: "The Dark Forest"
  - Quest Type: MAIN_STORY
  - Category: "Main Quest"
  - Prerequisites: [] (first main quest)
```

**Side Quest:**
```
Entity ID: QUEST_SIDE_HERBS
Quest Data:
  - Quest Name: "Herb Collection"
  - Quest Type: SIDE_QUEST
  - Category: "Gathering"
  - Prerequisites: [QUEST_WELCOME]  # Requires completion of welcome quest
```

**Daily Quest:**
```
Entity ID: QUEST_DAILY_MONSTERS
Quest Data:
  - Quest Name: "Monster Slayer"
  - Quest Type: DAILY
  - Category: "Combat"
  - Auto Complete: false  # Requires turn-in to NPC
```

---

## Part 2: Multi-Objective Quests

### Creating Complex Objectives

Create a quest with multiple objective types:

```
Entity ID: QUEST_INVESTIGATE_RUINS
Quest Name: "Investigate the Ancient Ruins"
```

**Objective 1 - REACH_LOCATION:**
```
ID: "find_ruins"
Type: REACH_LOCATION
Description: "Find the Ancient Ruins"
Target: LOCATION_RUINS (entity reference)
Target Quantity: 1
Hidden: false
```

**Objective 2 - KILL:**
```
ID: "clear_enemies"
Type: KILL
Description: "Defeat 5 Skeleton Warriors"
Target: ENEMY_SKELETON (entity reference)
Target Quantity: 5
Hidden: false
```

**Objective 3 - COLLECT:**
```
ID: "collect_artifact"
Type: COLLECT
Description: "Collect the Ancient Artifact"
Target: ITEM_ARTIFACT (entity reference)
Target Quantity: 1
Hidden: false
```

**Objective 4 - TALK:**
```
ID: "report_findings"
Type: TALK
Description: "Report to the Scholar"
Target: NPC_SCHOLAR (entity reference)
Target Quantity: 1
Hidden: false
```

---

## Part 3: Quest Tracking System

### Quest Tracker UI

Create `res://scenes/ui/quest_tracker.tscn`:

```
CanvasLayer (name: QuestTracker)
└── VBoxContainer
    ├── Label (title: "Active Quests")
    └── VBoxContainer (quest_list)
```

### Quest Tracker Script

```gdscript
extends CanvasLayer

@onready var quest_list = $VBoxContainer/QuestList

func _ready():
    # Connect to quest manager signals
    PPQuestManager.quest_added.connect(_on_quest_added)
    PPQuestManager.quest_removed.connect(_on_quest_removed)

    # Update on objective progress
    refresh_timer()

func refresh_timer():
    # Update every second
    var timer = Timer.new()
    add_child(timer)
    timer.timeout.connect(refresh_quests)
    timer.start(1.0)

func refresh_quests():
    # Clear list
    for child in quest_list.get_children():
        child.queue_free()

    # Show active quests
    var active_quests = PPQuestManager.get_active_quests()

    for quest in active_quests:
        add_quest_entry(quest)

func add_quest_entry(quest: PPRuntimeQuest):
    var entry = VBoxContainer.new()

    # Quest name
    var name_label = Label.new()
    name_label.text = quest.get_quest_name()
    name_label.add_theme_font_size_override("font_size", 14)
    entry.add_child(name_label)

    # Progress bar
    var progress = ProgressBar.new()
    progress.max_value = 100
    progress.value = quest.get_progress_percentage()
    progress.custom_minimum_size = Vector2(200, 20)
    entry.add_child(progress)

    # Objectives
    var objectives = quest.get_runtime_objectives()
    for i in range(objectives.size()):
        var obj = objectives[i]
        var obj_data = obj.get_quest_objective_instance()

        if obj_data and not obj_data.is_hidden():
            var obj_label = Label.new()
            var status = "✓" if obj.is_completed() else "○"
            obj_label.text = "  %s %s (%d/%d)" % [
                status,
                obj_data.get_description(),
                obj.get_current_progress(),
                obj_data.get_target_quantity()
            ]
            obj_label.add_theme_font_size_override("font_size", 12)
            entry.add_child(obj_label)

    quest_list.add_child(entry)

func _on_quest_added(quest: PPRuntimeQuest):
    refresh_quests()

func _on_quest_removed(quest: PPRuntimeQuest):
    refresh_quests()
```

---

## Part 4: Quest Log/Journal

### Quest Log UI

Create `res://scenes/ui/quest_log.tscn`:

```
CanvasLayer (name: QuestLog)
└── Panel
    ├── HBoxContainer
    │   ├── VBoxContainer (quest_categories)
    │   │   ├── Button ("All Quests")
    │   │   ├── Button ("Main Story")
    │   │   ├── Button ("Side Quests")
    │   │   └── Button ("Completed")
    │   └── VBoxContainer (quest_details)
    │       ├── Label (quest_name)
    │       ├── RichTextLabel (quest_description)
    │       ├── VBoxContainer (objectives_panel)
    │       └── VBoxContainer (rewards_panel)
    └── Button (close_button)
```

### Quest Log Script

```gdscript
extends CanvasLayer

@onready var panel = $Panel
@onready var all_button = $Panel/HBoxContainer/Categories/AllButton
@onready var main_button = $Panel/HBoxContainer/Categories/MainButton
@onready var side_button = $Panel/HBoxContainer/Categories/SideButton
@onready var completed_button = $Panel/HBoxContainer/Categories/CompletedButton
@onready var quest_name = $Panel/HBoxContainer/Details/QuestName
@onready var quest_description = $Panel/HBoxContainer/Details/Description
@onready var objectives_panel = $Panel/HBoxContainer/Details/ObjectivesPanel
@onready var rewards_panel = $Panel/HBoxContainer/Details/RewardsPanel
@onready var close_button = $Panel/CloseButton

var current_filter = "all"

func _ready():
    panel.hide()

    # Connect category buttons
    all_button.pressed.connect(_on_category_changed.bind("all"))
    main_button.pressed.connect(_on_category_changed.bind("main"))
    side_button.pressed.connect(_on_category_changed.bind("side"))
    completed_button.pressed.connect(_on_category_changed.bind("completed"))
    close_button.pressed.connect(_on_close_pressed)

func toggle():
    if panel.visible:
        panel.hide()
    else:
        show_log()

func show_log():
    refresh_quests()
    panel.show()

func _on_category_changed(filter: String):
    current_filter = filter
    refresh_quests()

func refresh_quests():
    var quests = get_filtered_quests()

    # Display first quest in list
    if quests.size() > 0:
        show_quest_details(quests[0])

func get_filtered_quests() -> Array:
    match current_filter:
        "all":
            return PPQuestManager.get_active_quests()
        "main":
            return PPQuestUtils.get_quests_by_type(
                PPQuestManager.get_active_quests(),
                PPQuest.QuestType.MAIN_STORY
            )
        "side":
            return PPQuestUtils.get_quests_by_type(
                PPQuestManager.get_active_quests(),
                PPQuest.QuestType.SIDE_QUEST
            )
        "completed":
            return PPQuestManager.get_completed_quests()

    return []

func show_quest_details(quest: PPRuntimeQuest):
    # Show quest info
    quest_name.text = quest.get_quest_name()
    quest_description.text = quest.get_description()

    # Clear objectives
    for child in objectives_panel.get_children():
        child.queue_free()

    # Show objectives
    var objectives = quest.get_runtime_objectives()
    for obj in objectives:
        var obj_data = obj.get_quest_objective_instance()
        if obj_data and not obj_data.is_hidden():
            var label = Label.new()
            var status = "[DONE]" if obj.is_completed() else "[%d/%d]" % [
                obj.get_current_progress(),
                obj_data.get_target_quantity()
            ]
            label.text = "%s %s" % [status, obj_data.get_description()]
            objectives_panel.add_child(label)

    # Clear rewards
    for child in rewards_panel.get_children():
        child.queue_free()

    # Show rewards
    var rewards = quest.get_rewards()
    for reward in rewards:
        var label = Label.new()
        label.text = "• " + get_reward_text(reward)
        rewards_panel.add_child(label)

func get_reward_text(reward) -> String:
    match reward.get_reward_type():
        PPQuestReward.RewardType.ITEM:
            var item = reward.get_reward_entity()
            return "%d x %s" % [reward.get_quantity(), item.get_item_name()]
        PPQuestReward.RewardType.CURRENCY:
            return "%d Gold" % reward.get_currency_amount()
        PPQuestReward.RewardType.EXPERIENCE:
            return "%d XP" % reward.get_experience_amount()
    return "Unknown Reward"

func _on_close_pressed():
    panel.hide()
```

---

## Part 5: Quest Markers

### World Marker System

Create visual markers for quest objectives in the game world.

```gdscript
# res://scripts/quest_marker_manager.gd
extends Node2D

const QuestMarker = preload("res://scenes/ui/quest_marker.tscn")

var markers: Dictionary = {}  # quest_id -> Array of marker nodes

func _ready():
    PPQuestManager.quest_added.connect(_on_quest_added)
    PPQuestManager.quest_removed.connect(_on_quest_removed)

    # Update markers periodically
    var timer = Timer.new()
    add_child(timer)
    timer.timeout.connect(update_all_markers)
    timer.start(0.5)

func _on_quest_added(quest: PPRuntimeQuest):
    create_markers_for_quest(quest)

func _on_quest_removed(quest: PPRuntimeQuest):
    remove_markers_for_quest(quest.get_quest_id())

func create_markers_for_quest(quest: PPRuntimeQuest):
    var quest_id = quest.get_quest_id()
    markers[quest_id] = []

    var objectives = quest.get_runtime_objectives()
    for obj in objectives:
        var obj_data = obj.get_quest_objective_instance()
        if not obj_data or obj.is_completed():
            continue

        # Get target position based on objective type
        var target_pos = get_objective_target_position(obj_data)
        if target_pos:
            var marker = create_marker(target_pos, obj_data.get_description())
            markers[quest_id].append(marker)

func create_marker(pos: Vector2, description: String) -> Node2D:
    var marker = QuestMarker.instantiate()
    marker.global_position = pos
    marker.tooltip_text = description
    add_child(marker)
    return marker

func get_objective_target_position(objective: PPQuestObjective) -> Vector2:
    var target_ref = objective.get_target_reference()
    if not target_ref:
        return Vector2.ZERO

    var target_entity = target_ref.get_entity()

    # Check if target is NPC
    if target_entity is PPNPCEntity:
        # Find NPC in scene
        var npcs = get_tree().get_nodes_in_group("npcs")
        for npc in npcs:
            if npc.npc_entity == target_entity:
                return npc.global_position

    # Check if target is location
    # (Assuming you have location markers in your scene)
    var locations = get_tree().get_nodes_in_group("locations")
    for location in locations:
        if location.location_id == target_entity.get_entity_id():
            return location.global_position

    return Vector2.ZERO

func remove_markers_for_quest(quest_id: String):
    if not markers.has(quest_id):
        return

    for marker in markers[quest_id]:
        marker.queue_free()

    markers.erase(quest_id)

func update_all_markers():
    for quest in PPQuestManager.get_active_quests():
        update_quest_markers(quest)

func update_quest_markers(quest: PPRuntimeQuest):
    # Remove completed objective markers
    var quest_id = quest.get_quest_id()
    if not markers.has(quest_id):
        return

    var to_remove = []
    for i in range(markers[quest_id].size()):
        var marker = markers[quest_id][i]
        var obj = quest.get_runtime_objectives()[i]
        if obj.is_completed():
            marker.queue_free()
            to_remove.append(i)

    # Remove from array in reverse order
    to_remove.sort()
    to_remove.reverse()
    for i in to_remove:
        markers[quest_id].remove_at(i)
```

### Quest Marker Scene

```gdscript
# res://scenes/ui/quest_marker.tscn -> script
extends Sprite2D

@export var bounce_height = 10.0
@export var bounce_speed = 2.0

var time = 0.0

func _process(delta):
    time += delta
    position.y = bounce_height * sin(time * bounce_speed)
```

---

## Part 6: Quest Chains

### Creating Quest Prerequisites

Quest chains ensure quests are completed in order.

**Chain Example: Village Defense**

```
QUEST_VILLAGE_DEFENSE_1: "Warning Signs"
  Prerequisites: []
  → Unlocks: QUEST_VILLAGE_DEFENSE_2

QUEST_VILLAGE_DEFENSE_2: "Prepare Defenses"
  Prerequisites: [QUEST_VILLAGE_DEFENSE_1]
  → Unlocks: QUEST_VILLAGE_DEFENSE_3

QUEST_VILLAGE_DEFENSE_3: "The Final Battle"
  Prerequisites: [QUEST_VILLAGE_DEFENSE_2]
  → Ends chain
```

### Checking Quest Availability

```gdscript
func get_available_quest_chains() -> Array:
    var completed_ids = PPQuestManager.get_completed_quest_ids()
    var all_quests = get_all_quest_entities()

    return PPQuestUtils.get_available_quests(all_quests, 1, completed_ids)

func show_quest_chain_progress(chain_name: String):
    var quests_in_chain = get_quests_by_chain(chain_name)

    print("=== %s Quest Chain ===" % chain_name)
    for quest in quests_in_chain:
        var quest_data = quest.get_quest_data()
        var status = "✓" if is_quest_completed(quest_data.get_quest_id()) else "○"
        print("%s %s" % [status, quest_data.get_quest_name()])

func get_quests_by_chain(chain_name: String) -> Array:
    # Filter quests by custom "chain" property
    var all_quests = get_all_quest_entities()
    return all_quests.filter(func(q):
        return q.get_string("chain") == chain_name
    )
```

---

## Part 7: Dynamic Quest Rewards

### Scaling Rewards by Level

```gdscript
func grant_quest_rewards(quest: PPRuntimeQuest, player_level: int):
    var rewards = quest.get_rewards()

    for reward in rewards:
        match reward.get_reward_type():
            PPQuestReward.RewardType.CURRENCY:
                # Scale gold by player level
                var base_gold = reward.get_currency_amount()
                var scaled_gold = base_gold * (1.0 + player_level * 0.1)
                player.inventory.add_currency(int(scaled_gold))
                print("Received %d gold" % scaled_gold)

            PPQuestReward.RewardType.EXPERIENCE:
                # Scale XP by player level
                var base_xp = reward.get_experience_amount()
                var scaled_xp = base_xp * (1.0 + player_level * 0.05)
                player.add_experience(int(scaled_xp))
                print("Received %d XP" % scaled_xp)

            PPQuestReward.RewardType.ITEM:
                # Give item (no scaling)
                var item = reward.get_reward_entity()
                var quantity = reward.get_quantity()
                player.inventory.add_item(item, quantity)
                print("Received %d x %s" % [quantity, item.get_item_name()])
```

### Random Reward Selection

```gdscript
func grant_random_reward(player):
    # Reward pool
    var possible_rewards = [
        {"type": "item", "entity_id": "HEALTH_POTION", "quantity": 3},
        {"type": "item", "entity_id": "MANA_POTION", "quantity": 3},
        {"type": "currency", "amount": 50},
        {"type": "item", "entity_id": "RANDOM_EQUIPMENT"}
    ]

    var reward = possible_rewards.pick_random()

    match reward["type"]:
        "item":
            var item = Pandora.get_entity(reward["entity_id"])
            player.inventory.add_item(item, reward.get("quantity", 1))
        "currency":
            player.inventory.add_currency(reward["amount"])
```

---

## Part 8: Objective Tracking

### Track KILL Objectives

```gdscript
# In enemy script
signal enemy_died(enemy_entity: PandoraEntity)

func die():
    enemy_died.emit(enemy_entity)

    # Track quest objectives
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_enemy_killed(quest, enemy_entity)

    queue_free()
```

### Track COLLECT Objectives

```gdscript
# In item pickup script
func _on_item_picked_up(item: PPItemEntity, quantity: int):
    # Add to inventory
    player.inventory.add_item(item, quantity)

    # Track quest objectives
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_item_collected(quest, item, quantity)
```

### Track REACH_LOCATION Objectives

```gdscript
# In location area script
extends Area2D

@export var location_entity_id: String

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if body.name == "Player":
        var location_entity = Pandora.get_entity(location_entity_id)

        # Track quest objectives
        for quest in PPQuestManager.get_active_quests():
            track_location_reached(quest, location_entity)

func track_location_reached(quest: PPRuntimeQuest, location):
    var objectives = quest.get_runtime_objectives()

    for i in range(objectives.size()):
        var obj = objectives[i]
        var obj_data = obj.get_quest_objective_instance()

        if obj_data.get_objective_type() == PPQuestObjective.ObjectiveType.REACH_LOCATION:
            var target = obj_data.get_target_reference().get_entity()
            if target.get_entity_id() == location.get_entity_id():
                obj.complete()
                print("Location reached!")
```

---

## Part 9: Quest Notifications

### Notification System

```gdscript
# res://scripts/notification_manager.gd
extends CanvasLayer

const Notification = preload("res://scenes/ui/notification.tscn")

@onready var notification_container = $VBoxContainer

func _ready():
    # Connect to quest signals
    PPQuestManager.quest_completed.connect(_on_quest_completed)
    PPQuestManager.objective_completed.connect(_on_objective_completed)

func _on_quest_completed(quest: PPRuntimeQuest):
    show_notification("Quest Completed: %s" % quest.get_quest_name(), Color.GOLD)

func _on_objective_completed(quest_id: String, objective_index: int):
    var quest = PPQuestManager.get_quest_by_id(quest_id)
    if quest:
        var obj = quest.get_runtime_objectives()[objective_index]
        var obj_data = obj.get_quest_objective_instance()
        show_notification("Objective Complete: %s" % obj_data.get_description(), Color.GREEN)

func show_notification(text: String, color: Color = Color.WHITE):
    var notification = Notification.instantiate()
    notification.text = text
    notification.modulate = color
    notification_container.add_child(notification)

    # Auto-remove after 3 seconds
    await get_tree().create_timer(3.0).timeout
    notification.queue_free()
```

---

## Part 10: Testing Your Quest System

### Test Checklist

- [ ] Create multiple quests with different types
- [ ] Test quest chain prerequisites
- [ ] Verify all objective types work (KILL, COLLECT, TALK, REACH_LOCATION)
- [ ] Test quest tracker updates in real-time
- [ ] Verify quest log shows correct information
- [ ] Test quest markers appear at correct locations
- [ ] Confirm rewards are granted correctly
- [ ] Test save/load preserves quest progress

---

## Next Steps

You now have a fully functional quest system! Try adding:

1. **Timed Quests** - Add deadlines for quests (Premium feature)
2. **Reputation Rewards** - Quests that increase faction reputation (Premium feature)
3. **Quest Failure Conditions** - Quests that can fail
4. **Hidden Objectives** - Surprise objectives revealed during quest
5. **Branching Quests** - Player choices affect quest outcomes

---

## See Also

- [Quest System Documentation](../core-systems/quest-system.md)
- [PPQuestUtils API](../utilities/quest-utils.md)
- [Building an Inventory UI](building-inventory-ui.md)

---

*Tutorial for Pandora+ v1.0.0*
