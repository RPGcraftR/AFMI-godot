# AzgaarMap Method Reference

This is a complete function reference for the `AzgaarMap` resource.

---

## Convenience Functions

Convenience functions combine coordinate lookup, cell mapping, and property resolution into a single call for ease of use.  

These cover most of the use cases. Other functions are internal helpers that are exposed anyway in cases where the return value being a `Dictionary` is unfavoured and a directly returned `integer` ID is preferred instead. (for example, comparisons that happen in `_process()` or `_physics_process()` that need to be completed in as less time as possible.)

### `Dictionary biome_at_pixel(pixel: Vector2i)`
Retrieves the biome dictionary corresponding to a specific pixel coordinate.

* **Parameters:**
  * `pixel`: `Vector2i` - The pixel coordinate on the map.
* **Return:**
  * `Dictionary` - The biome details dictionary, or an empty dictionary if out of bounds.

### `Dictionary culture_at_pixel(pixel: Vector2i)`
Retrieves the culture dictionary corresponding to a specific pixel coordinate.

* **Parameters:**
  * `pixel`: `Vector2i` - The pixel coordinate on the map.
* **Return:**
  * `Dictionary` - The culture details dictionary, or an empty dictionary if out of bounds.

### `Dictionary religion_at_pixel(pixel: Vector2i)`
Retrieves the religion dictionary corresponding to a specific pixel coordinate.

* **Parameters:**
  * `pixel`: `Vector2i` - The pixel coordinate on the map.
* **Return:**
  * `Dictionary` - The religion details dictionary, or an empty dictionary if out of bounds.

### `Dictionary state_at_pixel(pixel: Vector2i)`
Retrieves the state dictionary corresponding to a specific pixel coordinate.

* **Parameters:**
  * `pixel`: `Vector2i` - The pixel coordinate on the map.
* **Return:**
  * `Dictionary` - The state details dictionary, or an empty dictionary if out of bounds.

### `Dictionary burg_at_pixel(pixel: Vector2i)`
Retrieves the burg dictionary corresponding to a specific pixel coordinate.

* **Parameters:**
  * `pixel`: `Vector2i` - The pixel coordinate on the map.
* **Return:**
  * `Dictionary` - The burg details dictionary, or an empty dictionary if out of bounds.

### `Dictionary province_at_pixel(pixel: Vector2i)`
Retrieves the province dictionary corresponding to a specific pixel coordinate.

* **Parameters:**
  * `pixel`: `Vector2i` - The pixel coordinate on the map.
* **Return:**
  * `Dictionary` - The province details dictionary, or an empty dictionary if out of bounds.

### `Dictionary river_at_pixel(pixel: Vector2i)`
Retrieves the river dictionary corresponding to a specific pixel coordinate.

* **Parameters:**
  * `pixel`: `Vector2i` - The pixel coordinate on the map.
* **Return:**
  * `Dictionary` - The river details dictionary, or an empty dictionary if out of bounds.

### `Dictionary feature_at_pixel(pixel: Vector2i)`
Retrieves the feature dictionary corresponding to a specific pixel coordinate.

* **Parameters:**
  * `pixel`: `Vector2i` - The pixel coordinate on the map.
* **Return:**
  * `Dictionary` - The feature details dictionary, or an empty dictionary if out of bounds.

---

## General & Coordinate Functions

### `int cell_id_at_pixel(pixel: Vector2i)`
Finds the cell ID corresponding to a given pixel coordinate.

* **Parameters:**
  * `pixel`: `Vector2i` - The pixel coordinate to query.
* **Return:**
  * `int` - The cell ID, or `-1` if the pixel is outside map bounds.

---

## Default Properties

Default properties are packed into bitfields within `cell_data`.

### `Array def_prop_ids_at_cell(cell_id: int)`
Unpacks all default property IDs for a given cell.

* **Parameters:**
  * `cell_id`: `int` - The ID of the cell.
* **Return:**
  * `Array` - An array of IDs `[biome_id, culture_id, religion_id, state_id, height]`, or `[-1, -1, -1, -1, -1]` for invalid cell IDs.

### `int biome_id_at_cell(cell_id: int)`
Gets the biome ID for a specific cell.

* **Parameters:**
  * `cell_id`: `int` - The ID of the cell.
* **Return:**
  * `int` - The biome ID, or `-1` if invalid.

### `Dictionary biome_by_id(id: int)`
Retrieves the full biome details dictionary by its ID.

* **Parameters:**
  * `id`: `int` - The biome ID.
* **Return:**
  * `Dictionary` - The biome details, or `{}` if invalid.

### `int culture_id_at_cell(cell_id: int)`
Gets the culture ID for a specific cell.

* **Parameters:**
  * `cell_id`: `int` - The ID of the cell.
* **Return:**
  * `int` - The culture ID, or `-1` if invalid.

### `Dictionary culture_by_id(id: int)`
Retrieves the full culture details dictionary by its ID.

* **Parameters:**
  * `id`: `int` - The culture ID.
* **Return:**
  * `Dictionary` - The culture details, or `{}` if invalid.

### `int religion_id_at_cell(cell_id: int)`
Gets the religion ID for a specific cell.

* **Parameters:**
  * `cell_id`: `int` - The ID of the cell.
* **Return:**
  * `int` - The religion ID, or `-1` if invalid.

### `Dictionary religion_by_id(id: int)`
Retrieves the full religion details dictionary by its ID.

* **Parameters:**
  * `id`: `int` - The religion ID.
* **Return:**
  * `Dictionary` - The religion details, or `{}` if invalid.

### `int state_id_at_cell(cell_id: int)`
Gets the state ID for a specific cell.

* **Parameters:**
  * `cell_id`: `int` - The ID of the cell.
* **Return:**
  * `int` - The state ID, or `-1` if invalid.

### `Dictionary state_by_id(id: int)`
Retrieves the full state details dictionary by its ID.

* **Parameters:**
  * `id`: `int` - The state ID.
* **Return:**
  * `Dictionary` - The state details, or `{}` if invalid.

### `int height_at_cell(cell_id: int)`
Gets the height value for a specific cell.

* **Parameters:**
  * `cell_id`: `int` - The ID of the cell.
* **Return:**
  * `int` - The height value, or `-1` if invalid.

---

## Extensive Properties

Extensive properties map cell IDs to secondary structures (burgs, provinces, rivers, features).

### `int burg_id_at_cell(cell_id: int)`
Gets the burg ID for a specific cell.

* **Parameters:**
  * `cell_id`: `int` - The ID of the cell.
* **Return:**
  * `int` - The burg ID, or `-1` if invalid.

### `Dictionary burg_by_id(id: int)`
Retrieves the full burg details dictionary by its ID.

* **Parameters:**
  * `id`: `int` - The burg ID.
* **Return:**
  * `Dictionary` - The burg details, or `{}` if invalid.

### `int province_id_at_cell(cell_id: int)`
Gets the province ID for a specific cell.

* **Parameters:**
  * `cell_id`: `int` - The ID of the cell.
* **Return:**
  * `int` - The province ID, or `-1` if invalid.

### `Dictionary province_by_id(id: int)`
Retrieves the full province details dictionary by its ID.

* **Parameters:**
  * `id`: `int` - The ID of the cell.
* **Return:**
  * `Dictionary` - The province details, or `{}` if invalid.

### `int river_id_at_cell(cell_id: int)`
Gets the river ID for a specific cell.

* **Parameters:**
  * `cell_id`: `int` - The ID of the cell.
* **Return:**
  * `int` - The river ID, or `-1` if invalid.

### `Dictionary river_by_id(id: int)`
Retrieves the full river details dictionary by its ID.

* **Parameters:**
  * `id`: `int` - The river ID.
* **Return:**
  * `Dictionary` - The river details, or `{}` if invalid.

### `int feature_id_at_cell(cell_id: int)`
Gets the feature ID for a specific cell.

* **Parameters:**
  * `cell_id`: `int` - The ID of the cell.
* **Return:**
  * `int` - The feature ID, or `-1` if invalid.

### `Dictionary feature_by_id(id: int)`
Retrieves the full feature details dictionary by its ID.

* **Parameters:**
  * `id`: `int` - The feature ID.
* **Return:**
  * `Dictionary` - The feature details, or `{}` if invalid.

---

## Internal Helper Functions

> [!WARNING]
> **Internal Functions:** The following underscored functions are internal helpers used for bitfield packing and unpacking. **They are not to be called directly.**

### `int _pack_bits(biome: int, culture: int, religion: int, state: int, height: int)`
Packs biome, culture, religion, state, and height values into a single 32-bit integer.

* **Parameters:** 
  * `biome`: `int` (4 bits)
  * `culture`: `int` (7 bits)
  * `religion`: `int` (7 bits)
  * `state`: `int` (7 bits)
  * `height`: `int` (7 bits)
* **Return:** 
  * `int` - The packed 32-bit integer containing all property IDs.

### `Array[int] _unpack_bits(int32: int)`
Unpacks a 32-bit integer into individual property and height IDs.

* **Parameters:** 
  * `int32`: `int` - The packed 32-bit integer from `cell_data`.
* **Return:** 
  * `Array[int]` - An array containing `[biome, culture, religion, state, height]`.
