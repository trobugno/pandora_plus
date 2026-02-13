# PPStatusEffect

**Extends:** `RefCounted` 

Defines and manages the properties of a Status Effect, such as a buff or a debuff, that can be applied to an entity.

---

## Description

The `PPStatusEffect` class is a data container used to define all aspects of a status effect. These aspects include the unique identifier, description, duration, and the specifics of the **Tick System** which handles periodic effects over time.

![Status Effect](../assets/screenshots/status_effect.png ':size=600')

It is commonly used in conjunction with the Runtime Stats system (`PPRuntimeStats`) to apply temporary stat modifiers or continuous damage/healing effects.

---

## Properties

The properties of the class correspond to the fields visible in the Pandora editor UI screenshot.

| Property (Variable) | Type | UI Field Name | Description |
|---------------------|------|---------------|-------------|
| `_status_ID` | `String` | ID / Source | The unique identifier of the status effect. |
| `_description` | `String` | Description | Textual description of the effect. |
| `_duration` | `float` | Duration | The total duration of the effect in seconds. A value of `0` typically indicates an instantaneous or permanent effect. |
| `_status_key` | `int` | *None* | A numerical key associated with the status effect (not exposed in the UI)[cite: 1, 2]. |
| `_value_in_percentage` | `bool` | % Toggle | Flag to determine if the value per tick is a percentage (the toggle next to **Value per tick**)[cite: 1, 2]. |
| `_value_per_tick` | `float` | Value per tick | The magnitude of the value applied with each tick[cite: 1, 2]. |
| `_ticks` | `int` | Ticks | The number of times the effect will "tick" before the duration ends[cite: 1, 2]. |
| `_tick_type` | `int` | Type | The specific type or mechanism of the tick system[cite: 1, 3]. |

---

## Constructor

###### `_init(status_ID: String, status_key: int, description: String, duration: float, value_in_percentage: bool, value_per_tick: float, ticks: int, tick_type: int) -> void`

Initializes a new `PPStatusEffect` instance with all necessary parameters.

**Parameters:**
- `status_ID`: The unique identifier string.
- `status_key`: The numerical key.
- `description`: The effect description.
- `duration`: The effect duration in seconds.
- `value_in_percentage`: If the tick value is a percentage.
- `value_per_tick`: The value applied per tick.
- `ticks`: The total number of ticks.
- `tick_type`: The tick mechanism type.

---

## Methods

###### `load_data(data: Dictionary) -> void`

Loads the property data from a serialized dictionary[cite: 2].

###### `save_data(fields_settings: Array[Dictionary]) -> Dictionary`

Serializes the status effect properties into a dictionary for saving[cite: 3]. It uses the `fields_settings` array to only save properties that are enabled in the editor UI (e.g., `"enabled": true`)[cite: 3].

###### `_to_string() -> String`

Provides a string representation of the object for debugging purposes[cite: 3].
**Returns:** A string in the format: `<PPStatusEffect [ <_status_ID> ]>`[cite: 3].

---

## Tick System Details

The **Tick System** defines how an effect is applied periodically over its duration.

* **Type (`_tick_type`):** Defines the underlying logic or timing for the tick event.
* **Ticks (`_ticks`):** The total count of times the periodic effect should occur.
* **Value per tick (`_value_per_tick`):** The magnitude of the effect applied at each tick event.

The associated toggle (`_value_in_percentage`) determines if the **Value per tick** is treated as an absolute value or a percentage.

## Stacking Rule

The **Stacking Rule** toggle (Yes/No in the UI) is a UI representation of logic handled by a higher-level Status Effect Manager system. It is not stored in the core properties of `PPStatusEffect`. This higher-level system uses the `_status_ID` to determine if a newly applied effect should be ignored, refreshed, or stacked with an existing one.

---

## See Also

- [PPStatModifier](../api/stat-modifier.md) - The class used to define statistic modifiers.
- [PPRuntimeStats](../api/runtime-stats.md) - The stats system that applies modifiers and often uses Status Effects.

---

*API Reference generated from source code v1.1.1-core | v1.0.0-premium*