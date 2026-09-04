Technincal details and known issues.

### Memory Usage

The `AzgaarMap` resource holds all data. It's possible to crudely estimate RAM usage of a map before importing using the following formula.

- Memory needed to hold `Mapdata`,
	`map height * map width * 4 * scale`<sup>2</sup> Bytes
- Memory needed to hold `Cell data` (default properties),
	`cell count * 4` Bytes
- Memory needed to hold extensive properties,
	`cell count * 4 * number of enabled extensive properties` Bytes
- A small amount of additional memory (usually less than 1MB) is needed to hold Dictionaries containing Colors, Names etc.. This value changes depending on the number of distinct values each property has and the number of enabled extensive properties.

### Bitmap generation

For fast out of order retrieval, the voronoi data is rendered into a bitmap at import. This bitmap is then saved in a flattened `PackedInt32Array`. 

The obvious best choice for such a task is the proven scanline fill algorithm. However, I couldn't get scanline fill working in cases where a cell can be smaller than a pixel without upscaling everything and downscaling again (which defeats the whole purpose.). If you have an implementation that can handle such cases while providing higher performance, feel free to open a PR.

The algorithm currently used in rendering is the usual euclidean minimal distance method optimized using AABBs. This is obviously **NOT** the most efficient method. It's used because it's *reasonably* simple while being *reasonably* memory and CPU efficient. An expanded and commented python implementation of the `render_bitmap()` function found in the importer is presented below as reference for anyone who wants to improve upon it.


```python
def aabb_euclidean(limx, limy, cell_array, vertex_array, scale):
    rangeX = int(limx * scale)
    rangeY = int(limy * scale)
    bitmap = np.zeros((rangeX, rangeY), int)

    for cell in cell_array:
        verticesX = []
        verticesY = []
        for vertex in cell["v"]:
            vx = vertex_array[vertex]["p"][0] * scale
            vy = vertex_array[vertex]["p"][1] * scale
            verticesX.append(round(vx))
            verticesY.append(round(vy))

        # To prevent out of bound errors due to rounding.
        minX = max(0, min(verticesX))
        minY = max(0, min(verticesY))
        maxX = min(rangeX, max(verticesX))
        maxY = min(rangeY, max(verticesY))

        for ax in range(minX, maxX):
            for ay in range(minY, maxY):
                distances = []
                for neighbor in cell["c"]:
                    nx = cell_array[neighbor]["p"][0] * scale
                    ny = cell_array[neighbor]["p"][1] * scale
                    distances.append(distance_sqto([nx, ny], [ax, ay]))

                # Current cell coordinates.
                cx = cell["p"][0] * scale
                cy = cell["p"][1] * scale

                if min(distances) < distance_sqto([ax, ay], [cx, cy]):
		        # A neighboring cell is closer to the pixel than the current cell.
                    # Index of the closest cell as in neighboring cells array.
                    closest_cell_index = distances.index(min(distances))
                    # Assign the closest cell ID.
                    bitmap[ax, ay] = cell["c"][closest_cell_index]
                else:
                    # Current cell is the closest cell.
                    bitmap[ax, ay] = cell["i"]

    return bitmap
```


### Celldata array

This array holds all default property IDs as 32 bit integers in a `PackedInt32Array` indexed by cell ID. Bit packing and unpacking is done by `_pack_bits` and `_unpack_bits` functions in `AzgaarMap` resource. See reference.md for reference.

### Setting map values

This is **NOT** supported and there are no helpers for setting any value after import. **However**, it's possible to write directly to data arrays. None of the arrays are especially designed with any thread safety. So, proceed at your own risk if you use threads to set values.