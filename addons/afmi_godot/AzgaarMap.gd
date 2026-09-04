@tool
class_name AzgaarMap
extends Resource

@export_category("Metadata")
@export var size : Vector2i
@export var scale : float
@export_category("Data")
#coords --> Cell ID array
@export var mapdata : PackedInt32Array
#Cell ID --> biome,culture,religion,state,height
@export var cell_data : PackedInt32Array
#Cell ID --> other properties 
@export var burgs_array : PackedInt32Array
@export var provinces_array : PackedInt32Array
@export var rivers_array : PackedInt32Array
@export var features_array : PackedInt32Array
#Property ID --> Property details (biome,culture,religion,state,height)
@export var biomes : Array
@export var cultures : Array
@export var religions : Array
@export var states : Array
#Property ID --> Property details (other)
@export var burgs : Array
@export var provinces : Array
@export var rivers : Array
@export var features : Array

#Helper functions. Not to be called directly.
#biome = 4 bits
#Culture = 7bits
#religion = 7 bits
#State = 7 bits
#Height = 7 bits
#In that order
func _pack_bits(biome,culture,religion,state,height) -> int:
	return ((biome & 0xF) << 28) | ((culture & 0x7F) << 21) | ((religion & 0x7F) << 14) | ((state & 0x7F) << 7) | (height & 0x7F)

func _unpack_bits(int32) -> Array[int]:
	var ids : Array[int]
	ids.resize(5)
	ids[0] = (int32 >> 28) & 0b1111 #Biome
	ids[1] = (int32 >> 21) & 0b1111111 #Culture
	ids[2] = (int32 >> 14) & 0b1111111 #religion
	ids[3] = (int32 >> 7) & 0b1111111 #State
	ids[4] = int32 & 0b1111111 #Height
	return ids

func cell_id_at_pixel(pixel:Vector2i) -> int:
	if pixel.x < 0 or pixel.x >= size.x*scale or pixel.y < 0 or pixel.y >= size.y*scale:
		return -1
	else:
		return mapdata[roundi(pixel.x)*roundi(size.y*scale)+roundi(pixel.y)]

#Default properties
func def_prop_ids_at_cell(cell_id:int) -> Array:
	if cell_id < 0:
		return [-1,-1,-1,-1,-1]
	else:
		return _unpack_bits(cell_data[cell_id])

func biome_id_at_cell(cell_id:int) -> int:
	if cell_id < 0:
		return -1
	else:
		return _unpack_bits(cell_data[cell_id])[0]

func biome_by_id(id:int) -> Dictionary:
	if id < 0:
		return {}
	else:
		return biomes[id]

func culture_id_at_cell(cell_id:int) -> int:
	if cell_id < 0:
		return -1
	else:
		return _unpack_bits(cell_data[cell_id])[1]

func culture_by_id(id:int) -> Dictionary:
	if id < 0:
		return {}
	else:
		return cultures[id]

func religion_id_at_cell(cell_id:int) -> int:
	if cell_id < 0:
		return -1
	else:
		return _unpack_bits(cell_data[cell_id])[2]

func religion_by_id(id:int) -> Dictionary:
	if id < 0:
		return {}
	else:
		return religions[id]

func state_id_at_cell(cell_id:int) -> int:
	if cell_id < 0:
		return -1
	else:
		return _unpack_bits(cell_data[cell_id])[3]

func state_by_id(id:int) -> Dictionary:
	if id < 0:
		return {}
	else:
		return states[id]

func height_at_cell(cell_id:int) -> int:
	if cell_id < 0:
		return -1
	else:
		return _unpack_bits(cell_data[cell_id])[4]

#Extensive properties
func burg_id_at_cell(cell_id:int) -> int:
	if cell_id < 0 or burgs_array == null or burgs_array.size() == 0:
		return -1
	else:
		return burgs_array[cell_id]

func burg_by_id(id:int) -> Dictionary:
	if id < 0 or burgs == null or burgs.size() == 0:
		return {}
	else:
		return burgs[id]

func province_id_at_cell(cell_id:int) -> int:
	if cell_id < 0 or provinces_array == null or provinces_array.size() == 0:
		return -1
	else:
		return provinces_array[cell_id]

func province_by_id(id:int) -> Dictionary:
	if id < 0 or provinces == null or provinces.size() == 0:
		return {}
	else:
		return provinces[id]

func river_id_at_cell(cell_id:int) -> int:
	if cell_id < 0 or rivers_array == null or rivers_array.size() == 0:
		return -1
	else:
		return rivers_array[cell_id]

func river_by_id(id:int) -> Dictionary:
	if id < 0 or rivers == null or rivers.size() == 0:
		return {}
	else:
		return rivers[id]

func feature_id_at_cell(cell_id:int) -> int:
	if cell_id < 0 or features_array == null or features_array.size() == 0:
		return -1
	else:
		return features_array[cell_id]

func feature_by_id(id:int) -> Dictionary:
	if id < 0 or features == null or features.size() == 0:
		return {}
	else:
		return features[id]
#Convinience functions
func biome_at_pixel(pixel:Vector2i) -> Dictionary:
	return biome_by_id(biome_id_at_cell(cell_id_at_pixel(pixel)))

func culture_at_pixel(pixel:Vector2i) -> Dictionary:
	return culture_by_id(culture_id_at_cell(cell_id_at_pixel(pixel)))

func religion_at_pixel(pixel:Vector2i) -> Dictionary:
	return religion_by_id(religion_id_at_cell(cell_id_at_pixel(pixel)))

func state_at_pixel(pixel:Vector2i) -> Dictionary:
	return state_by_id(state_id_at_cell(cell_id_at_pixel(pixel)))

func burg_at_pixel(pixel:Vector2i) -> Dictionary:
	return burg_by_id(burg_id_at_cell(cell_id_at_pixel(pixel)))

func province_at_pixel(pixel:Vector2i) -> Dictionary:
	return province_by_id(province_id_at_cell(cell_id_at_pixel(pixel)))

func river_at_pixel(pixel:Vector2i) -> Dictionary:
	return river_by_id(river_id_at_cell(cell_id_at_pixel(pixel)))

func feature_at_pixel(pixel:Vector2i) -> Dictionary:
	return feature_by_id(feature_id_at_cell(cell_id_at_pixel(pixel)))
