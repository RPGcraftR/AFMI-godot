#  Overview

This is an overview of AFMI-Godot plugin to import Azgaar's FMG maps into Godot. Please note that the addon does **NOT** support all properties exported by the map exporter. Only the following fields are made available as of right now. 

- **Default Properties** (Properties that are available by default without specifically enabling in importer settings)
	- Biome
	- Culture
	- Religion
	- State
	- Height
	>[!IMPORTANT]
	>**Bit Packed Values:** These properties are stored in a single `PackedInt32Array` to reduce memory usage. As such, `biome` count is limited to 16, `culture`,`religion`,`state` counts are limited to 128.  `height` value is unaffected as it's always mapped to [0,100]. See `_pack_bits` referece for technical details.
- **Extensive Properties** (Properties that need to be enabled in importer settings as necessary)
	- Burgs
	- Provinces
	- Rivers
	- Features
	>[!CAUTION]
	> **Extensive Properties:** These properties are each stored in their own `PackedInt32Array` (because there is no upper limit to these values) as opposed to a single bit-packed `PackedInt32Array` used by default properties. Because of that, enabling one of these arrays will consume an amount of memory equal to all default properties combined.

>[!IMPORTANT]
>**Supported Export Types:** This plugin only supports `Full JSON` exports exported directly from Azgaar's Fantasy Map Generator. `Grid Cells`,`Pack Cells` and `Minimal JSON` exports from the exporter and direct `*.map` files are **NOT** supported.

More fields will not be added unless requested. If you need a specific field added, feel free to open an issue and discuss.

This plugin is implemented in two parts.
- An `EditorImportPlugin` that adds to the Godot resource import system an import option for `*.json` files. 
- An `AzgaarMap` resource that holds imported map data in a *reasonably efficient* data structure.

---
## 1)Import Dock

The import option `AzgaarMap` in Godot import dock. When opening a `*.json` file, you should see the following screen in the import dock.

![Godot import dock for a JSON file after enabling AFMI-Godot plugin](/img/import-dock.png)

#### Import Options

- **Sampling Scale:** (Default = 1)
	Specifices scaling applied to the map at importing. This can be used to import a high resolution map into a lower resolution map resource to reduce memory usage. Doesn't affect the cell count.
	
	Example :  Importing a 1000x1000 (in FMG options) map with 0.5 `Sampling Scale` will give a resource that behaves as if the map was originally generated in 500x500 resolution.
- **Burgs:** (Default = false)
	Whether to save `Burgs` information in map resource. Required if you need to use  `burg_at_pixel`, `burg_id_at_cell`, `burg_by_id` methods.
- **Provinces:** (Default = false)
	Whether to save `Provinces` information in map resource. Required if you need to use  `province_at_pixel`, `province_id_at_cell`, `province_by_id` methods.
- **Rivers:** (Default = false)
	Whether to save `Rivers` information in map resource. Required if you need to use  `river_at_pixel`, `river_id_at_cell`, `river_by_id` methods.
- **Features:** (Default = false)
	Whether to save `Features` information in map resource. Required if you need to use  `feature_at_pixel`, `feature_id_at_cell`, `feature_by_id` methods.
- **Render Images:** (Default = false)
	Whether to render `png` image maps of `biomes`, `states`,`provinces`,`rivers` and `burgs` and save them.
	>[!INFO]
	>**Image Formats:** Rendered `biomes` , `states`,`provinces` images will be in format `Image.FORMAT_RGBF`.
	>`rivers` and `burgs` images will be in format `Image.FORMAT_R8`.
	
- ** Image save path:** (Default = "")
	A directory path indicating where to export images. Effective only when `Render Images` is set to `true`. 

---
## 2)AzgaarMap resource

The custom resource `AzgaarMap`. Saves all map related data and provides methods to get any value by pixel in O(1) time.

Values in the resource are **NOT** designed to be changed after creation. Although there is nothing preventing a script from modifying data arrays, it's strongly discouraged.

![AzgaarMap resource attached to a script in the inspector](/img/azgaarmap-resource.png)

### Export Variables

- **Size:** Original size of the map as in `[info][height]` and `[info][width]` of JSON file. Must be multplied by `scale` for actual pixel count along each direction.
- **Mapdata:** A `PackedInt32Array` of size `width`x`height`x`scale`<sup>2</sup>. Holds one `cell_id` per pixel.
- **Cell Data:** A `PackedInt32Array` with a size equal to the number of cells in map. Holds a single 32 bit integer per cell that contains bit packed default properties.
- **Burgs Array,Provinces Array,Rivers Array,Features Array:** `PackedInt32Array`s of size equal to the number of cells in map. Holds a single 32 bit integer per cell per array. Each array contains info about which cell has which property.
- **Biomes, Cultures, Religions, States, Burgs, Provinces, Rivers, Features Arrays:** 
	These arrays contain `Dictionaries` of metadata about different types of `biomes`, `cultures`, `religions`, `states`, `burgs`, `provinces` and `rivers`. Length of each array depends of how many different types of each property are there in the map. 
	>[!INFO]
	>For memory saving, it's possible to manually clear some of these arrays if it's abosultely certain that relevant `*_at_pixel` and `*_by_id` methods will **NOT** be called. However, this is highly discouraged as the gain is at most a few kilobytes in exchange for unexpected behavior.
	
---
# Reading Values

<p float="left">
  <img src="/img/azgaar-web-editor-map.png" width="49%" />
  <img src="/img/godot-editor-map.png" width="49%" />
</p>


> [!IMPORTANT]
> Due to the way Azgaar Maps are exported, the coordinate system origin is at top left corner. Since the map is imported as-is the coordinate system remains the same when retrieving values. All pixel coordinates always originate from top left corner of the map.

>[!INFO]
	>`Dictionary` types returned by such returning functions are 1:1 replicas of the ones found in `[pack]` section of the JSON file with only difference being having hex code color strings converted to Godot native `Color` types. Allowing direct use of `[color]` property.

The AzgaarMap resource provides methods to,

#### Get by pixel

- Get Cell ID that owns a pixel
	Use `cell_id_at_pixel(pixel:Vector2i)` to get `int` cell ID of the cell that owns the pixel.
- Get `biome`/ `culture`/ `religion`/`state`/`burg`, `province`/`river`/`feature` dictionaries of a pixel.
	Use `*_at_pixel(pixel:Vector2i)` (replacing `*` with property name) to get `Dictionary` typed `biome`/ `culture`/ `religion`/ `state`/ `burg`/ `province`/`river`/`feature` data of the cell that own the pixel.


#### Get by cell ID

- Get `biome`/ `culture`/ `religion`/`state`/`burg`, `province`/`river`/`feature` IDs of a cell.
	Use `*_id_at_cell(cell_id:int)` (replacing `*` with property name) to get integer IDs (e.g., `biome_id_at_cell`, `culture_id_at_cell`, `religion_id_at_cell`, `state_id_at_cell`, `height_at_cell`, `burg_id_at_cell`, `province_id_at_cell`, `river_id_at_cell`, `feature_id_at_cell`).
- Get full details dictionary by ID.
	Use `*_by_id(id:int)` to retrieve metadata dictionaries for specific entities (`biome_by_id`, `culture_by_id`, `religion_by_id`, `state_by_id`, `burg_by_id`, `province_by_id`, `river_by_id`, `feature_by_id`).
- Unpack all default properties at once.
	Use `def_prop_ids_at_cell(cell_id:int)` to return an `Array` containing `[biome_id, culture_id, religion_id, state_id, height]`.

---

## Conclusion & Best Practices

When querying map data during runtime, keep the following best practices in mind:
- **Performance-Critical Code:** For checks occurring frequently within `_process()` or `_physics_process()`, prefer fetching integer IDs (`*_id_at_cell`) rather than full dictionaries to minimize allocation overhead.
- **Optional Feature Enabling:** Ensure that extensive properties (such as burgs, provinces, rivers, and features) are enabled in the import dock before calling their respective lookup methods.
- **Bounds Checking:** Always verify that cell IDs and pixel coordinates are valid (i.e. not returning `-1` or empty dictionaries) before performing game logic dependent on map regions.
