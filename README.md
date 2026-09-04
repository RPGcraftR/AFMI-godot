# AFMI-Godot Plugin

AFMI-Godot is a Godot plugin designed to import Azgaar's Fantasy Map Generator (FMG) maps into Godot projects.

>[!NOTE]
>As of right now, Godot 4.7.2 has been tested and confirmed to work.
>The plugin should work on all Godot versions 4.7+. <br>
>Latest Azgaar FMG (v1.150.0) is supported. Older versions may work. Depends on the changes to the Datamodel from FMG side.


---

### Installation

1. Clone this repository or download the repository as a zip and extract it.
2. Copy `addons` directory into your project directory.
3. Open Godot editor and enable AFMI-Godot plugin in Settings -> Plugins.
4. Restart the editor.

---

### Documentation

- [Quickstart](https://github.com/RPGcraftR/AFMI-godot/wiki/Quickstart)
- [Overview](https://github.com/RPGcraftR/AFMI-godot/wiki/Overview)
- [Reference](https://github.com/RPGcraftR/AFMI-godot/wiki/Reference)
- [Technical details and limitations](https://github.com/RPGcraftR/AFMI-godot/wiki/Notes)

## Basics

The plugin consists of two main parts:
- An **EditorImportPlugin** that integrates an import option for `*.json` files into Godot's resource import system.
- An **AzgaarMap** custom resource that holds imported map data in a memory-efficient data structure and provides O(1) time lookup by pixel coordinate or cell ID.

### Supported Export Types
- **Supported:** `Full JSON` exports directly exported from Azgaar's Fantasy Map Generator.
- **Not Supported:** `Grid Cells`, `Pack Cells`, `Minimal JSON` exports, and direct `*.map` files.

### Properties
- **Default Properties** (included automatically without extensive settings):
  - Biome (limited to 16 types)
  - Culture (limited to 128 types)
  - Religion (limited to 128 types)
  - State (limited to 128 types)
  - Height (due to exporter limitations, mapped to [0,100])
  *Note:* Default properties are stored in a single bit-packed `PackedInt32Array` to save memory.
- **Extensive Properties** (must be manually enabled in import settings):
  - Burgs
  - Provinces
  - Rivers
  - Features
  <br>
  *Drawback:* Each extensive property is stored in its own full `PackedInt32Array`. Enabling a single extensive property consumes memory roughly equal to all default properties combined.

---

## Import Options

When selecting a `*.json` file in the Godot FileSystem dock, the Import dock provides the following settings:
- **Sampling Scale** (Default: `1`): Scales the map during import to lower resolution without altering cell counts.
- **Burgs** (Default: `false`): Saves burgs data. Required for `burg_at_pixel`, `burg_id_at_cell`, and `burg_by_id`.
- **Provinces** (Default: `false`): Saves provinces data. Required for `province_at_pixel`, `province_id_at_cell`, and `province_by_id`.
- **Rivers** (Default: `false`): Saves rivers data. Required for `river_at_pixel`, `river_id_at_cell`, and `river_by_id`.
- **Features** (Default: `false`): Saves features data. Required for `feature_at_pixel`, `feature_id_at_cell`, and `feature_by_id`.
- **Render Images** (Default: `false`): Renders and saves PNG image maps for biomes, states, provinces, rivers, and burgs. (Biomes, states, and provinces render in `Image.FORMAT_RGBF`; rivers and burgs in `Image.FORMAT_R8`.)
- **Image Save Path** (Default: `""`): Directory path for exported images when rendering is enabled.

---

## Quickstart

1. Place your **Full JSON** export file into your Godot project folder.
2. Select the file in Godot and configure options in the **Import** dock.
3. Click **Reimport**.
4. Attach the imported `AzgaarMap` resource to your script.

### Example Usage

```gdscript
extends Node2D

@export var azgaar_map: AzgaarMap

func _ready() -> void:
    if not azgaar_map:
        return
        
    var sample_pixel = Vector2i(250, 150)
    var state_info = azgaar_map.state_at_pixel(sample_pixel)
    
    if not state_info.is_empty():
        print("State name: ", state_info["name"])
        var state_color: Color = state_info["color"]
        print("State color: ", state_color)

    var cell_id = azgaar_map.cell_id_at_pixel(sample_pixel)
    if cell_id != -1:
        var biome_id = azgaar_map.biome_id_at_cell(cell_id)
        print("Biome ID: ", biome_id)
```

---

## API Summary

- **Pixel Lookups:** `cell_id_at_pixel(pixel)`, `biome_at_pixel(pixel)`, `culture_at_pixel(pixel)`, `religion_at_pixel(pixel)`, `state_at_pixel(pixel)`, `burg_at_pixel(pixel)`, `province_at_pixel(pixel)`, `river_at_pixel(pixel)`, `feature_at_pixel(pixel)`.
- **Cell ID Lookups:** `def_prop_ids_at_cell(cell_id)`, `biome_id_at_cell(cell_id)`, `culture_id_at_cell(cell_id)`, `religion_id_at_cell(cell_id)`, `state_id_at_cell(cell_id)`, `height_at_cell(cell_id)`, `burg_id_at_cell(cell_id)`, `province_id_at_cell(cell_id)`, `river_id_at_cell(cell_id)`, `feature_id_at_cell(cell_id)`.
- **ID Metadata Lookups:** `biome_by_id(id)`, `culture_by_id(id)`, `religion_by_id(id)`, `state_by_id(id)`, `burg_by_id(id)`, `province_by_id(id)`, `river_by_id(id)`, `feature_by_id(id)`.

*Note:* Coordinate origin is at the top-left corner (`Vector2i(0, 0)`).

---

## Drawbacks & Known Limitations

- **Limited Export Support:** Only Full JSON exports from Azgaar's FMG are supported. Grid cells, pack cells, minimal JSON, and raw `.map` files are rejected.
- **Memory Overhead of Extensive Properties:** Enabling extensive properties (Burgs, Provinces, Rivers, Features) scales memory usage significantly because each occupies a dedicated `PackedInt32Array` equal in size to the cell count.
- **Bit-Packing Constraints:** Default properties are bit-packed into a single `PackedInt32Array`, limiting Biomes to 16, and Cultures, Religions, and States to 128 items each.
- **Immutability & Editing:** Values inside the resource are not designed to be modified after creation. There are no helper functions for setting map values post-import, and modifying data arrays manually is discouraged and not thread-safe.
- **Bitmap Generation Method:** Bitmap generation uses an Euclidean minimal distance method optimized with AABBs instead of a scanline fill algorithm, which makes it less efficient.
