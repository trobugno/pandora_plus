# Building an Inventory UI

A complete guide to creating a professional inventory and equipment UI with drag-and-drop, tooltips, and visual feedback.

**Difficulty:** Intermediate
**Time:** ~90 minutes
**Prerequisites:** [Create Your First RPG](first-rpg.md) tutorial completed

---

## What You'll Build

A professional inventory system with:

- ✅ Grid-based inventory with drag-and-drop
- ✅ Equipment slots with visual previews
- ✅ Item tooltips with stats
- ✅ Stack splitting and merging
- ✅ Item sorting and filtering
- ✅ Currency display
- ✅ Context menus (use, equip, drop)
- ✅ Visual feedback and animations

---

## Part 1: Inventory Slot Component

### Create Inventory Slot Scene

Create `res://scenes/ui/inventory_slot.tscn`:

```
PanelContainer (name: InventorySlot)
├── MarginContainer
│   └── VBoxContainer
│       ├── TextureRect (item_icon)
│       └── Label (quantity_label)
```

### Inventory Slot Script

```gdscript
# res://scripts/ui/inventory_slot.gd
extends PanelContainer
class_name InventorySlot

signal slot_clicked(slot: InventorySlot)
signal slot_right_clicked(slot: InventorySlot)
signal item_dropped(from_slot: InventorySlot, to_slot: InventorySlot)

@onready var item_icon = $MarginContainer/VBoxContainer/ItemIcon
@onready var quantity_label = $MarginContainer/VBoxContainer/QuantityLabel

var slot_index: int = -1
var item: PPItemEntity = null
var quantity: int = 0

# Drag and drop
var is_dragging = false
var drag_preview: Control = null

func _ready():
    custom_minimum_size = Vector2(64, 64)
    gui_input.connect(_on_gui_input)

    # Setup drag and drop
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func set_item(p_item: PPItemEntity, p_quantity: int = 1):
    item = p_item
    quantity = p_quantity

    if item:
        # Set icon
        var texture = item.get_texture()
        if texture:
            item_icon.texture = texture
            item_icon.show()
        else:
            item_icon.hide()

        # Set quantity
        if quantity > 1:
            quantity_label.text = str(quantity)
            quantity_label.show()
        else:
            quantity_label.hide()

        # Set rarity color
        var rarity = item.get_rarity()
        if rarity:
            modulate = get_rarity_color(rarity.get_rarity_name())
    else:
        clear()

func clear():
    item = null
    quantity = 0
    item_icon.hide()
    quantity_label.hide()
    modulate = Color.WHITE

func is_empty() -> bool:
    return item == null

func get_rarity_color(rarity_name: String) -> Color:
    match rarity_name:
        "Common": return Color.WHITE
        "Uncommon": return Color.GREEN
        "Rare": return Color.BLUE
        "Epic": return Color.PURPLE
        "Legendary": return Color.ORANGE
    return Color.WHITE

func _on_gui_input(event: InputEvent):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                # Start drag
                if not is_empty():
                    start_drag()
                slot_clicked.emit(self)
            else:
                # End drag
                end_drag()

        elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            slot_right_clicked.emit(self)

func start_drag():
    if is_empty():
        return

    is_dragging = true

    # Create drag preview
    drag_preview = PanelContainer.new()
    drag_preview.modulate.a = 0.7

    var texture_rect = TextureRect.new()
    texture_rect.texture = item.get_texture()
    texture_rect.custom_minimum_size = Vector2(48, 48)
    drag_preview.add_child(texture_rect)

    get_tree().root.add_child(drag_preview)
    drag_preview.global_position = get_global_mouse_position()

func end_drag():
    if not is_dragging:
        return

    is_dragging = false

    # Check if dropped on another slot
    var drop_target = get_slot_under_mouse()

    if drop_target and drop_target != self:
        item_dropped.emit(self, drop_target)

    # Remove drag preview
    if drag_preview:
        drag_preview.queue_free()
        drag_preview = null

func get_slot_under_mouse() -> InventorySlot:
    var mouse_pos = get_global_mouse_position()

    # Find all InventorySlot nodes
    var all_slots = get_tree().get_nodes_in_group("inventory_slots")

    for slot in all_slots:
        if slot is InventorySlot and slot.get_global_rect().has_point(mouse_pos):
            return slot

    return null

func _process(delta):
    if is_dragging and drag_preview:
        drag_preview.global_position = get_global_mouse_position()

func _on_mouse_entered():
    if not is_empty():
        show_tooltip()

func _on_mouse_exited():
    hide_tooltip()

func show_tooltip():
    # Emit signal for tooltip manager
    get_tree().call_group("tooltip_manager", "show_item_tooltip", item, global_position)

func hide_tooltip():
    get_tree().call_group("tooltip_manager", "hide_tooltip")
```

---

## Part 2: Main Inventory Panel

### Create Inventory Panel Scene

Create `res://scenes/ui/inventory_panel.tscn`:

```
CanvasLayer (name: InventoryPanel, groups: ["inventory_ui"])
└── Panel
    ├── VBoxContainer
    │   ├── HBoxContainer (header)
    │   │   ├── Label ("Inventory")
    │   │   ├── HSeparator
    │   │   ├── Button (sort_button: "Sort")
    │   │   └── Button (close_button: "×")
    │   ├── HBoxContainer (filters)
    │   │   ├── Button ("All")
    │   │   ├── Button ("Weapons")
    │   │   ├── Button ("Armor")
    │   │   └── Button ("Consumables")
    │   ├── GridContainer (inventory_grid)
    │   └── HBoxContainer (footer)
    │       ├── Label (weight_label)
    │       └── Label (currency_label)
```

### Inventory Panel Script

```gdscript
# res://scripts/ui/inventory_panel.gd
extends CanvasLayer

var player

@onready var panel = $Panel
@onready var inventory_grid = $Panel/VBoxContainer/InventoryGrid
@onready var sort_button = $Panel/VBoxContainer/Header/SortButton
@onready var close_button = $Panel/VBoxContainer/Header/CloseButton
@onready var weight_label = $Panel/VBoxContainer/Footer/WeightLabel
@onready var currency_label = $Panel/VBoxContainer/Footer/CurrencyLabel

# Filter buttons
@onready var all_filter = $Panel/VBoxContainer/Filters/AllButton
@onready var weapons_filter = $Panel/VBoxContainer/Filters/WeaponsButton
@onready var armor_filter = $Panel/VBoxContainer/Filters/ArmorButton
@onready var consumables_filter = $Panel/VBoxContainer/Filters/ConsumablesButton

var current_filter = "all"
var inventory_slots: Array[InventorySlot] = []

func _ready():
    panel.hide()

    # Configure grid
    inventory_grid.columns = 6

    # Connect buttons
    sort_button.pressed.connect(_on_sort_pressed)
    close_button.pressed.connect(_on_close_pressed)

    # Connect filters
    all_filter.pressed.connect(_on_filter_changed.bind("all"))
    weapons_filter.pressed.connect(_on_filter_changed.bind("weapons"))
    armor_filter.pressed.connect(_on_filter_changed.bind("armor"))
    consumables_filter.pressed.connect(_on_filter_changed.bind("consumables"))

    # Connect to inventory signals
    if player and player.inventory:
        player.inventory.inventory_updated.connect(_on_inventory_updated)
        player.inventory.item_added.connect(_on_item_changed)
        player.inventory.item_removed.connect(_on_item_changed)

func _input(event):
    if event.is_action_pressed("ui_cancel"):  # ESC key
        toggle()

func toggle():
    if panel.visible:
        panel.hide()
    else:
        show_inventory()

func show_inventory():
    if not player:
        return

    create_inventory_slots()
    update_display()
    panel.show()

func create_inventory_slots():
    # Clear existing slots
    for child in inventory_grid.get_children():
        child.queue_free()

    inventory_slots.clear()

    # Create slots
    var max_slots = player.inventory.max_items_in_inventory
    if max_slots == -1:
        max_slots = 30  # Default size for unlimited inventory

    for i in range(max_slots):
        var slot = preload("res://scenes/ui/inventory_slot.tscn").instantiate()
        slot.slot_index = i
        slot.add_to_group("inventory_slots")

        # Connect signals
        slot.slot_clicked.connect(_on_slot_clicked)
        slot.slot_right_clicked.connect(_on_slot_right_clicked)
        slot.item_dropped.connect(_on_item_dropped)

        inventory_grid.add_child(slot)
        inventory_slots.append(slot)

    update_slots()

func update_slots():
    var filtered_items = get_filtered_items()
    var display_index = 0

    for slot in inventory_slots:
        if display_index < filtered_items.size():
            var inv_slot = filtered_items[display_index]
            if inv_slot and inv_slot.item:
                slot.set_item(inv_slot.item, inv_slot.quantity)
            else:
                slot.clear()
            display_index += 1
        else:
            slot.clear()

func get_filtered_items() -> Array:
    var all_items = player.inventory.all_items.duplicate()

    match current_filter:
        "all":
            return all_items
        "weapons":
            return all_items.filter(func(slot):
                if not slot or not slot.item:
                    return false
                return slot.item is PPEquipmentEntity and slot.item.get_equipment_slot() == "WEAPON"
            )
        "armor":
            return all_items.filter(func(slot):
                if not slot or not slot.item:
                    return false
                return slot.item is PPEquipmentEntity and slot.item.get_equipment_slot() in ["HEAD", "CHEST", "LEGS"]
            )
        "consumables":
            return all_items.filter(func(slot):
                if not slot or not slot.item:
                    return false
                return slot.item.get_stackable()
            )

    return all_items

func update_display():
    update_slots()
    update_footer()

func update_footer():
    # Update weight
    var total_weight = PPInventoryUtils.calculate_total_weight(player.inventory)
    weight_label.text = "Weight: %.1f" % total_weight

    # Update currency
    currency_label.text = "Gold: %d" % player.inventory.game_currency

func _on_filter_changed(filter: String):
    current_filter = filter
    update_display()

func _on_sort_pressed():
    PPInventoryUtils.sort_inventory(player.inventory, "value")
    update_display()

func _on_close_pressed():
    panel.hide()

func _on_inventory_updated():
    if panel.visible:
        update_display()

func _on_item_changed(_item, _quantity):
    if panel.visible:
        update_display()

func _on_slot_clicked(slot: InventorySlot):
    if slot.is_empty():
        return

    # Double-click to use/equip
    # (Implement double-click detection as needed)

func _on_slot_right_clicked(slot: InventorySlot):
    if slot.is_empty():
        return

    # Show context menu
    show_context_menu(slot)

func _on_item_dropped(from_slot: InventorySlot, to_slot: InventorySlot):
    # Swap items
    PPInventoryUtils.swap_items(
        player.inventory,
        from_slot.slot_index,
        to_slot.slot_index
    )

func show_context_menu(slot: InventorySlot):
    # Create context menu
    var popup = PopupMenu.new()
    add_child(popup)

    popup.add_item("Use", 0)
    popup.add_item("Equip", 1)
    popup.add_item("Drop", 2)

    popup.id_pressed.connect(func(id):
        _on_context_menu_selected(id, slot)
        popup.queue_free()
    )

    popup.popup(Rect2(get_global_mouse_position(), Vector2(100, 60)))

func _on_context_menu_selected(id: int, slot: InventorySlot):
    match id:
        0:  # Use
            use_item(slot.item)
        1:  # Equip
            equip_item(slot.item)
        2:  # Drop
            drop_item(slot.item)

func use_item(item: PPItemEntity):
    # TODO: Implement item usage
    print("Using item: ", item.get_item_name())

func equip_item(item: PPItemEntity):
    if item is PPEquipmentEntity:
        PPEquipmentUtils.equip_item(player.inventory, item, player.runtime_stats)

func drop_item(item: PPItemEntity):
    player.inventory.remove_item(item, 1)
    print("Dropped: ", item.get_item_name())
```

---

## Part 3: Equipment Panel

### Create Equipment Panel Scene

Create `res://scenes/ui/equipment_panel.tscn`:

```
Panel (name: EquipmentPanel)
└── VBoxContainer
    ├── Label ("Equipment")
    ├── GridContainer (equipment_slots)
    │   ├── Label ("Head:")
    │   ├── InventorySlot (head_slot)
    │   ├── Label ("Chest:")
    │   ├── InventorySlot (chest_slot)
    │   ├── Label ("Legs:")
    │   ├── InventorySlot (legs_slot)
    │   ├── Label ("Weapon:")
    │   ├── InventorySlot (weapon_slot)
    │   ├── Label ("Shield:")
    │   ├── InventorySlot (shield_slot)
    │   ├── Label ("Accessory 1:")
    │   ├── InventorySlot (accessory1_slot)
    │   ├── Label ("Accessory 2:")
    │   └── InventorySlot (accessory2_slot)
    └── VBoxContainer (stats_panel)
        ├── Label ("Stats")
        ├── Label (health_label)
        ├── Label (attack_label)
        └── Label (defense_label)
```

### Equipment Panel Script

```gdscript
# res://scripts/ui/equipment_panel.gd
extends Panel

var player

@onready var head_slot = $VBoxContainer/EquipmentSlots/HeadSlot
@onready var chest_slot = $VBoxContainer/EquipmentSlots/ChestSlot
@onready var legs_slot = $VBoxContainer/EquipmentSlots/LegsSlot
@onready var weapon_slot = $VBoxContainer/EquipmentSlots/WeaponSlot
@onready var shield_slot = $VBoxContainer/EquipmentSlots/ShieldSlot
@onready var accessory1_slot = $VBoxContainer/EquipmentSlots/Accessory1Slot
@onready var accessory2_slot = $VBoxContainer/EquipmentSlots/Accessory2Slot

@onready var health_label = $VBoxContainer/StatsPanel/HealthLabel
@onready var attack_label = $VBoxContainer/StatsPanel/AttackLabel
@onready var defense_label = $VBoxContainer/StatsPanel/DefenseLabel

var slot_mapping = {}

func _ready():
    # Map slots to equipment slots
    slot_mapping = {
        "HEAD": head_slot,
        "CHEST": chest_slot,
        "LEGS": legs_slot,
        "WEAPON": weapon_slot,
        "SHIELD": shield_slot,
        "ACCESSORY_1": accessory1_slot,
        "ACCESSORY_2": accessory2_slot
    }

    # Connect to equipment signals
    PPEquipmentUtils.equipment_equipped.connect(_on_equipment_changed)
    PPEquipmentUtils.equipment_unequipped.connect(_on_equipment_changed)

    # Connect slot clicks
    for slot_name in slot_mapping:
        var slot = slot_mapping[slot_name]
        slot.slot_clicked.connect(_on_equipment_slot_clicked.bind(slot_name))
        slot.item_dropped.connect(_on_item_dropped_on_equipment)

func refresh():
    update_equipment_slots()
    update_stats()

func update_equipment_slots():
    for slot_name in slot_mapping:
        var ui_slot = slot_mapping[slot_name]

        if player.inventory.has_equipment_in_slot(slot_name):
            var equipped = player.inventory.get_equipped_item(slot_name)
            var item = equipped.item as PPEquipmentEntity
            ui_slot.set_item(item, 1)
        else:
            ui_slot.clear()

func update_stats():
    if not player or not player.runtime_stats:
        return

    # Get total equipment bonuses
    var bonuses = PPEquipmentUtils.get_total_equipment_stats(player.inventory)

    # Display stats with equipment bonuses
    var health = player.runtime_stats.get_effective_stat("health")
    var attack = player.runtime_stats.get_effective_stat("attack")
    var defense = player.runtime_stats.get_effective_stat("defense")

    health_label.text = "HP: %d" % health
    if bonuses.has("health"):
        health_label.text += " (+%d)" % bonuses["health"]

    attack_label.text = "ATK: %d" % attack
    if bonuses.has("attack"):
        attack_label.text += " (+%d)" % bonuses["attack"]

    defense_label.text = "DEF: %d" % defense
    if bonuses.has("defense"):
        defense_label.text += " (+%d)" % bonuses["defense"]

func _on_equipment_slot_clicked(slot_name: String):
    # Unequip on click
    if player.inventory.has_equipment_in_slot(slot_name):
        PPEquipmentUtils.unequip_item(player.inventory, slot_name, player.runtime_stats)

func _on_item_dropped_on_equipment(from_slot: InventorySlot, to_slot: InventorySlot):
    if from_slot.is_empty():
        return

    var item = from_slot.item

    # Check if item is equipment
    if item is PPEquipmentEntity:
        PPEquipmentUtils.equip_item(player.inventory, item, player.runtime_stats)

func _on_equipment_changed(_stats, _slot, _item):
    refresh()
```

---

## Part 4: Item Tooltip

### Create Tooltip Scene

Create `res://scenes/ui/item_tooltip.tscn`:

```
PanelContainer (name: ItemTooltip, groups: ["tooltip_manager"])
└── VBoxContainer
    ├── Label (item_name)
    ├── HSeparator
    ├── Label (item_type)
    ├── RichTextLabel (description)
    ├── HSeparator
    ├── VBoxContainer (stats_container)
    └── Label (value_label)
```

### Tooltip Script

```gdscript
# res://scripts/ui/item_tooltip.gd
extends PanelContainer

@onready var item_name = $VBoxContainer/ItemName
@onready var item_type = $VBoxContainer/ItemType
@onready var description = $VBoxContainer/Description
@onready var stats_container = $VBoxContainer/StatsContainer
@onready var value_label = $VBoxContainer/ValueLabel

func _ready():
    hide()
    add_to_group("tooltip_manager")

func show_item_tooltip(item: PPItemEntity, anchor_position: Vector2):
    # Set item info
    item_name.text = item.get_item_name()
    description.text = item.get_description()

    # Set rarity color
    var rarity = item.get_rarity()
    if rarity:
        item_name.modulate = get_rarity_color(rarity.get_rarity_name())

    # Set item type
    if item is PPEquipmentEntity:
        var equipment = item as PPEquipmentEntity
        item_type.text = "Equipment - %s" % equipment.get_equipment_slot()

        # Show stats
        show_equipment_stats(equipment)
    else:
        item_type.text = "Item"
        clear_stats()

    # Set value
    value_label.text = "Value: %d gold" % item.get_value()

    # Position tooltip
    global_position = anchor_position + Vector2(70, 0)

    show()

func show_equipment_stats(equipment: PPEquipmentEntity):
    clear_stats()

    if not equipment.has_stat_bonuses():
        return

    var stats = equipment.get_equipment_stats()

    if stats._health > 0:
        add_stat_label("+%d Health" % stats._health, Color.GREEN)
    if stats._mana > 0:
        add_stat_label("+%d Mana" % stats._mana, Color.CYAN)
    if stats._attack > 0:
        add_stat_label("+%d Attack" % stats._attack, Color.RED)
    if stats._defense > 0:
        add_stat_label("+%d Defense" % stats._defense, Color.BLUE)
    if stats._crit_rate > 0:
        add_stat_label("+%.1f%% Crit Rate" % stats._crit_rate, Color.YELLOW)
    if stats._crit_damage > 0:
        add_stat_label("+%.1f%% Crit Damage" % stats._crit_damage, Color.ORANGE)

func add_stat_label(text: String, color: Color):
    var label = Label.new()
    label.text = text
    label.modulate = color
    stats_container.add_child(label)

func clear_stats():
    for child in stats_container.get_children():
        child.queue_free()

func hide_tooltip():
    hide()

func get_rarity_color(rarity_name: String) -> Color:
    match rarity_name:
        "Common": return Color.WHITE
        "Uncommon": return Color.GREEN
        "Rare": return Color.BLUE
        "Epic": return Color.PURPLE
        "Legendary": return Color.ORANGE
    return Color.WHITE
```

---

## Part 5: Combined Character Screen

### Create Character Screen Scene

Create `res://scenes/ui/character_screen.tscn`:

```
CanvasLayer (name: CharacterScreen)
└── Panel
    ├── HBoxContainer
    │   ├── EquipmentPanel (left panel)
    │   └── InventoryPanel (right panel)
    └── ItemTooltip
```

### Character Screen Script

```gdscript
# res://scripts/ui/character_screen.gd
extends CanvasLayer

var player

@onready var equipment_panel = $Panel/HBoxContainer/EquipmentPanel
@onready var inventory_panel = $Panel/HBoxContainer/InventoryPanel
@onready var panel = $Panel

func _ready():
    panel.hide()

func _input(event):
    if event.is_action_pressed("ui_character"):  # I key
        toggle()

func toggle():
    if panel.visible:
        panel.hide()
    else:
        show_character()

func show_character():
    if not player:
        return

    # Set player reference
    equipment_panel.player = player
    inventory_panel.player = player

    # Refresh displays
    equipment_panel.refresh()
    inventory_panel.show_inventory()

    panel.show()
```

---

## Part 6: Visual Effects

### Slot Hover Effect

Add to InventorySlot script:

```gdscript
var original_modulate: Color

func _on_mouse_entered():
    if not is_empty():
        # Brighten on hover
        original_modulate = modulate
        modulate = modulate.lightened(0.3)
        show_tooltip()

func _on_mouse_exited():
    modulate = original_modulate
    hide_tooltip()
```

### Item Add Animation

```gdscript
func animate_item_add():
    var tween = create_tween()
    scale = Vector2(1.5, 1.5)
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
```

### Drag Preview with Shadow

```gdscript
func create_drag_preview():
    drag_preview = PanelContainer.new()

    # Add shadow
    var shadow = PanelContainer.new()
    shadow.modulate = Color(0, 0, 0, 0.5)
    shadow.position = Vector2(2, 2)
    drag_preview.add_child(shadow)

    # Add icon
    var texture_rect = TextureRect.new()
    texture_rect.texture = item.get_texture()
    texture_rect.custom_minimum_size = Vector2(48, 48)
    drag_preview.add_child(texture_rect)

    get_tree().root.add_child(drag_preview)
```

---

## Part 7: Advanced Features

### Stack Splitting

```gdscript
func split_stack(slot: InventorySlot):
    if slot.quantity <= 1:
        return

    var split_amount = floor(slot.quantity / 2.0)

    # Find empty slot
    var empty_slot = find_empty_slot()
    if empty_slot:
        # Create new stack
        empty_slot.set_item(slot.item, split_amount)

        # Reduce original stack
        slot.quantity -= split_amount
        slot.set_item(slot.item, slot.quantity)

func find_empty_slot() -> InventorySlot:
    for slot in inventory_slots:
        if slot.is_empty():
            return slot
    return null
```

### Quick Transfer

```gdscript
func quick_transfer_to_equipment(slot: InventorySlot):
    if not slot.item is PPEquipmentEntity:
        return

    var equipment = slot.item as PPEquipmentEntity

    # Shift+Click to equip
    if Input.is_key_pressed(KEY_SHIFT):
        PPEquipmentUtils.equip_item(player.inventory, equipment, player.runtime_stats)
```

---

## Part 8: Input Actions

### Configure Input Map

Add to Project Settings → Input Map:

```
ui_character: I
ui_inventory: Tab
ui_sort: S (while inventory open)
ui_quick_use: Q
```

### Keyboard Shortcuts

```gdscript
func _input(event):
    if not panel.visible:
        return

    # Sort inventory
    if event.is_action_pressed("ui_sort"):
        _on_sort_pressed()

    # Close with ESC
    if event.is_action_pressed("ui_cancel"):
        toggle()
```

---

## Part 9: Testing

### Test Checklist

- [ ] Drag and drop items between slots
- [ ] Tooltips show correct item information
- [ ] Equipment stats update when equipping/unequipping
- [ ] Context menu works on right-click
- [ ] Filters show correct items
- [ ] Sort button organizes inventory
- [ ] Currency and weight display correctly
- [ ] Visual effects play smoothly

---

## Part 10: Polish and Optimization

### Performance Tips

1. **Object Pooling** - Reuse slot objects instead of creating/destroying
2. **Lazy Updates** - Only refresh UI when visible
3. **Batch Operations** - Group inventory changes and update once

### Visual Polish

1. **Sound Effects** - Add sounds for equip, drop, pickup
2. **Particles** - Add sparkles for rare items
3. **Animations** - Smooth transitions between states

---

## Next Steps

You now have a professional inventory UI! Consider adding:

1. **Item Comparison** - Show stat differences when hovering over equipment
2. **Quick Slots** - Hotbar for consumables
3. **Search/Filter** - Text search for items
4. **Item Sets** - Visual indicators for equipment sets
5. **Durability System** - Show item condition

---

## See Also

- [Inventory System](../core-systems/inventory-system.md)
- [Equipment System](../core-systems/equipment-system.md)
- [PPInventoryUtils API](../utilities/inventory-utils.md)

---

*Tutorial for Pandora+ v1.0.0*
