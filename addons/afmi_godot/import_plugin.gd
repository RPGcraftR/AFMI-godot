@tool
extends EditorImportPlugin

enum Presets { DEFAULT }


func _get_importer_name():
	return "azgaarmap"

func _get_visible_name():
	return "AzgaarMap"

func _get_recognized_extensions():
	return ["json"]

func _get_save_extension():
	return "res"

func _get_resource_type():
	return "Resource"

func _get_preset_count():
	return Presets.size()

func _get_preset_name(preset_index):
	match preset_index:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

func _get_import_options(path, preset_index):
	match preset_index:
		Presets.DEFAULT:
			return [
	{
		"name": "sampling_scale",
		"default_value": 1.0,
		"property_hint": PropertyHint.PROPERTY_HINT_RANGE,
		"hint_string": "(0,1)"
	},
	{
		"name": "burgs",
		"default_value": false
	},
	{
		"name": "provinces",
		"default_value": false
	},
	{
		"name": "rivers",
		"default_value": false
	},
	{
		"name": "features",
		"default_value": false
	},
	{
		"name": "render_images",
		"default_value": false
	},
	{
		"name": "image_save_path",
		"default_value": "",
		"property_hint": PropertyHint.PROPERTY_HINT_DIR
	}
]
		_:
			return []

#Loading screen
var progress_dialog : AcceptDialog
var progress_label : Label
var resource : AzgaarMap
var biomes_map : Image
var states_map : Image
var provinces_map : Image
var rivers_map : Image
var burgs_map : Image

#Helper functions.
func hex_to_rgb(array : Array) -> Array:
	for i in array:
		if typeof(i) != Variant.Type.TYPE_INT and typeof(i) != Variant.Type.TYPE_FLOAT:
			i["color"] = Color(i["color"])
	return array

func id_to_color(map : Array,cell_array : Array,lookup_array :Array ,lookup_type : String,pos : Vector2) -> Color:
	return lookup_array[cell_array[map[pos.x][pos.y]][lookup_type]]["color"]

func trim_field(array : Array, key : String) -> Array:
	for i in array:
		if typeof(i) != Variant.Type.TYPE_INT and typeof(i) != Variant.Type.TYPE_FLOAT:
			i.erase(key)
	return array

#Workarounds for undocumented behaviour/differently structured 0th indices.
#Some need fixing from FMG side. 
#Fix for cases where 0th index of a property array is left without a color field.
func patch_idx0(array: Array) -> Array:
	# NOTE : Patching 0th index with white color for out-of-ordinary 0th indices in arrays.
	array[0]["color"] = "#000000"
	return array
#Some arrays (river) are out of order. Reorders them.
func reorder_array(array : Array, begins_with_1 = true) -> Array:
	var reordered : Array
	reordered.resize(len(array))
	for i in array:
		if typeof(i) != Variant.Type.TYPE_INT and typeof(i) != Variant.Type.TYPE_FLOAT:
			reordered[i["i"]] = i
	if begins_with_1:
		reordered[0] = 0
	return reordered
#Some arrays (provinces) have 0 at 0th index. 
#Replaces them with a dummy dictionary for visualizing.
func add_proper_idx0(array: Array) -> Array:
	array[0] = {"color":"#000000"}
	return array

#Core functions
func build_cell_arrays(cells:Array, switches : Array) -> Array:
	var n = len(cells)
	var cell_array : PackedInt32Array
	var bu_a : PackedInt32Array
	var pr_a : PackedInt32Array
	var ri_a : PackedInt32Array
	var ft_a : PackedInt32Array
	cell_array.resize(n)
	if switches[0]:
		bu_a.resize(n)
	if switches[1]:
		pr_a.resize(n)
	if switches[2]:
		ri_a.resize(n)
	if switches[3]:
		ft_a.resize(n)
	var ac #Active cell
	for i in range(len(cells)):
		ac = cells[i]
		cell_array[i] = resource._pack_bits(int(ac["biome"]),int(ac["culture"]),int(ac["religion"]),int(ac["state"]),int(ac["h"]))
		#Build extensive property arrays as necessary.
		if switches[0]:
			bu_a[i] = ac["burg"]
		if switches[1]:
			pr_a[i] = ac["province"]
		if switches[2]:
			ri_a[i] = ac["r"]
		if switches[3]:
			ft_a[i] = ac["f"]
	return [cell_array,bu_a,pr_a,ri_a,ft_a]

func render_bitmap(limx:int,limy:int,cell_array:Array,vertex_array:Array,factor:float):
	var bitmap : PackedInt32Array
	var rangeX = roundi(limx*factor)
	var rangeY = roundi(limy*factor)
	bitmap.resize(rangeX*rangeY)
	for cell in cell_array:
		var verticesX = []
		var verticesY = []
		for vertex in cell["v"]:
			verticesX.append(round(vertex_array[vertex]["p"][0]*factor))
			verticesY.append(round(vertex_array[vertex]["p"][1]*factor))
		for ax in range(max(0, verticesX.min()), min(rangeX, verticesX.max())):
			for ay in range(max(0, verticesY.min()), min(rangeY, verticesY.max())):
				var distances = []
				var pixel = Vector2(ax,ay)
				var selected_cell
				for neighbor in cell["c"]:
					distances.append(pixel.distance_squared_to(Vector2(cell_array[neighbor]["p"][0]*factor,cell_array[neighbor]["p"][1]*factor)))
				if distances.min() < pixel.distance_squared_to(Vector2(cell["p"][0]*factor,cell["p"][1]*factor)):
					selected_cell = cell["c"][distances.find(distances.min())]
				else:
					selected_cell = cell["i"]
				bitmap[ax*rangeY + ay] = selected_cell
	return bitmap

func process_map(map:Dictionary,sampling_scale,burgs,provinces,rivers,features):
	resource.size.x = map["info"]["width"]
	resource.size.y = map["info"]["height"]
	resource.scale = sampling_scale
	var vertices = map["pack"]["vertices"]
	#Default properties
	resource.biomes = hex_to_rgb(map["pack"]["biomes"])
	resource.states =  hex_to_rgb(patch_idx0(map["pack"]["states"]))
	resource.cultures = hex_to_rgb(patch_idx0(map["pack"]["cultures"]))
	resource.religions = hex_to_rgb(patch_idx0(map["pack"]["religions"]))
	#Extensive properties
	var mapdata_arrays = build_cell_arrays(map["pack"]["cells"],[burgs,provinces,rivers,features])
	if burgs:
		resource.burgs = map["pack"]["burgs"]
		resource.burgs_array = mapdata_arrays[1]
	if provinces:
		resource.provinces = hex_to_rgb(add_proper_idx0(map["pack"]["provinces"]))
		resource.provinces_array = mapdata_arrays[2]
	if rivers:
		resource.rivers = map["pack"]["rivers"]
		resource.rivers_array = mapdata_arrays[3]
	if features:
		resource.features = trim_field(map["pack"]["features"],"vertices")
		resource.features_array = mapdata_arrays[4]
	resource.cell_data = mapdata_arrays[0]
	resource.mapdata = render_bitmap(resource.size.x,resource.size.y,map["pack"]["cells"],vertices,sampling_scale)

#Visualize and save functions
func visualize_biomes(maps_save_path):
	var img = Image.create_empty(roundi(resource.size.x*resource.scale),roundi(resource.size.y*resource.scale),false,Image.FORMAT_RGBF)
	for i in roundi(resource.size.x*resource.scale):
		for j in roundi(resource.size.y*resource.scale):
			img.set_pixel(i,j,resource.biome_at_pixel(Vector2i(i,j))["color"])
	biomes_map = img
	biomes_map.save_png(maps_save_path + "/biomes.png")
	
func visualize_states(maps_save_path):
	var img = Image.create_empty(roundi(resource.size.x*resource.scale),roundi(resource.size.y*resource.scale),false,Image.FORMAT_RGBF)
	for i in roundi(resource.size.x*resource.scale):
		for j in roundi(resource.size.y*resource.scale):
			img.set_pixel(i,j,resource.state_at_pixel(Vector2i(i,j))["color"])
	states_map = img
	states_map.save_png(maps_save_path + "/states.png")

func visualize_provinces(maps_save_path):
	var img = Image.create_empty(roundi(resource.size.x*resource.scale),roundi(resource.size.y*resource.scale),false,Image.FORMAT_RGBF)
	for i in roundi(resource.size.x*resource.scale):
		for j in roundi(resource.size.y*resource.scale):
			img.set_pixel(i,j,resource.province_at_pixel(Vector2i(i,j))["color"])
	provinces_map = img
	provinces_map.save_png(maps_save_path + "/provinces.png")

func visualize_rivers(maps_save_path):
	var img = Image.create_empty(roundi(resource.size.x*resource.scale),roundi(resource.size.y*resource.scale),false,Image.FORMAT_R8)
	for i in roundi(resource.size.x*resource.scale):
		for j in roundi(resource.size.y*resource.scale):
			var active_cell_id = resource.cell_id_at_pixel(Vector2i(i,j))
			var is_river =Color(1,1,1) if resource.river_id_at_cell(active_cell_id) > 0 else Color(0,0,0)
			img.set_pixel(i,j,is_river)
	rivers_map = img
	rivers_map.save_png(maps_save_path + "/rivers.png")

func visualize_burgs(maps_save_path):
	var img = Image.create_empty(roundi(resource.size.x*resource.scale),roundi(resource.size.y*resource.scale),false,Image.FORMAT_R8)
	for i in roundi(resource.size.x*resource.scale):
		for j in roundi(resource.size.y*resource.scale):
			var active_cell_id = resource.cell_id_at_pixel(Vector2i(i,j))
			var is_burg =Color(1,1,1) if resource.burg_id_at_cell(active_cell_id) > 0 else Color(0,0,0)
			img.set_pixel(i,j,is_burg)
	burgs_map = img
	burgs_map.save_png(maps_save_path + "/burgs.png")

func _get_option_visibility(path, option_name, options):
	return true
	
func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	if not FileAccess.file_exists(source_file):
		return ERR_DOES_NOT_EXIST
		   
	var file = FileAccess.open(source_file, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	if json_string.strip_edges().is_empty():
		return ERR_FILE_CORRUPT  
	#Truncating all JSON after grid because of unicode issues.
	var grid_index = json_string.find('"grid"')
	if grid_index == -1:
		grid_index = json_string.find('grid') 
		 
	var final_json = ""
	if grid_index != -1:
		final_json = json_string.left(grid_index)
	else:
		final_json = json_string 
		   
	#Clean up leftover from beautification
	final_json = final_json.strip_edges()
	if final_json.ends_with(","):
		final_json = final_json.substr(0, final_json.length() - 1)
		final_json = final_json.strip_edges()
	final_json += "}"
	var json = JSON.new()
	var error = json.parse(final_json)
	#Check if parsing succeeded AND if the result is actually a Dictionary. 
	if error == OK and json.data is Dictionary:
		resource = AzgaarMap.new()
		process_map(json.data, options["sampling_scale"], options["burgs"], options["provinces"], options["rivers"], options["features"])
		if options["render_images"]:
			visualize_biomes(options["image_save_path"])
			r_gen_files.append(options["image_save_path"]+"/biomes.png")
			visualize_states(options["image_save_path"])
			r_gen_files.append(options["image_save_path"]+"/states.png")
			if options["provinces"]:
				visualize_provinces(options["image_save_path"]) 
				r_gen_files.append(options["image_save_path"]+"/provinces.png")
			if options["rivers"]:
				visualize_rivers(options["image_save_path"])
				r_gen_files.append(options["image_save_path"]+"/rivers.png")
			if options["burgs"]:
				visualize_burgs(options["image_save_path"])
				r_gen_files.append(options["image_save_path"]+"/burgs.png")
		return ResourceSaver.save(resource, save_path + "." + _get_save_extension())
	else:
		printerr(json.get_error_message())
		return ERR_PARSE_ERROR
	
