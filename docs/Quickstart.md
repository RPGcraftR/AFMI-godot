
# Quickstart: AFMI-Godot Plugin

This guide walks through importing an Azgaar FMG map into Godot and querying its data efficiently. Querying is done from the `AzgaarMap` resource and all methods support being called from within the editor. (contains `@tool` decorator.)

---

## Prerequisites & Important Warnings

- **Supported Export Type:** This plugin only supports **Full JSON** exports directly from Azgaar's Fantasy Map Generator. Other export types (such as Grid Cells, Pack Cells, Minimal JSON, or direct `*.map` files) are **not supported**.
- **Memory vs. Features:** 
  - **Default Properties** (Biomes, Cultures, Religions, States, and Heights) are included automatically and packed efficiently.
  - **Extensive Properties** (Burgs, Provinces, Rivers, and Features) must be enabled manually in the import settings if you plan to use them. Enabling them increases memory usage, so conservatively enable as required.

---

## Step 1: Importing the Map

1. Place your **Full JSON** export file into your Godot project folder.
2. Click on the file in the Godot FileSystem dock to open the **Import** dock.
3. Configure your import settings:
   - **Sampling Scale:** Adjust if you want to scale down a high-resolution map to save memory without changing the cell count.
   - **Extensive Properties:** Check **Burgs**, **Provinces**, **Rivers**, or **Features** as needed.
   - **Render Images:** Enable if you want Godot to automatically generate and save PNG image maps for biomes, states, provinces, rivers, and burgs.
1. Click **Reimport**. The JSON file will now behave as an `AzgaarMap` resource.

> [!IMPORTANT]
> **Coordinate System:** The coordinate system origin is located at the **top-left corner** (`Vector2i(0, 0)`). All pixel coordinates originate from this top-left corner. See overview.md#Reading Values for an explanation.

---

## Step 2: Accessing Map Data in Code

Attach the imported `AzgaarMap` resource to your script and query data using pixel coordinates or cell IDs.

### Example Script

```gdscript
extends Node2D

@export var azgaar_map: AzgaarMap

func _ready() -> void:
    if not azgaar_map:
        print("AzgaarMap resource not assigned!")
        
    # Example 1: Querying data by pixel coordinate
    var sample_pixel = Vector2i(250, 150)
    var state_info = azgaar_map.state_at_pixel(sample_pixel)
    
    if not state_info.is_empty():
        print("State at pixel: ", state_info["name"])
        # Hex color strings are automatically converted to Godot Color types
        var state_color: Color = state_info["color"]
        print("State color: ", state_color)

    # Example 2: Getting cell ID for performance-critical lookups
    var cell_id = azgaar_map.cell_id_at_pixel(sample_pixel)
    if cell_id != -1:
        var biome_id = azgaar_map.biome_id_at_cell(cell_id)
        print("Biome ID: ", biome_id)
```


Read reference.md for details about all available methods.

See notes.md for technical details and possible edge cases.

---

## Best Practices

- **Performance-Critical Code:** For checks occurring frequently within `_process()` or `_physics_process()`, prefer fetching integer IDs (such as `biome_id_at_cell`) rather than full dictionaries to minimize allocation overhead.
- **Bounds Checking:** Always verify that your pixel coordinates and cell IDs are valid (checking that cell IDs do not return `-1` and dictionaries are not empty) before executing game logic.
