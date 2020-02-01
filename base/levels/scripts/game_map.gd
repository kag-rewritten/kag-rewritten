extends Node2D

### Signals
signal map_loaded
### ---

onready var solid_shadow_layer = $SolidShadows
onready var tilemap = $TileMap
var tileset = TileSet.new()

### Customizable
export (String) var map_path
export (Array, String) var search_directories
export (Vector2) var tile_size = Vector2(8, 8)
### ---

var tile_array = []
var shadow_array = []

### Metadata
var tile_scenes = {}

var map_image
var map_width
var map_height
### ---

func _load_map():
	tilemap.tile_set = tileset
	_load_tiles()
	
	map_image = load(map_path)
	map_width = map_image.get_width()
	map_height = map_image.get_height()
	shadow_array.resize(map_width * map_height)
	tile_array.resize(map_width * map_height)
	
	var tmp_id
	var tmp_scene
	var tmp_state
	
	var tmp_pixel
	var tmp_index
	
	map_image.lock()
	for x in range(map_width):
		for y in range(map_height):
			tmp_pixel = map_image.get_pixel(x, y)
			tmp_id = TileInfo._get_id_from(tmp_pixel)
			tmp_index = x + y * map_width
			
			if tile_scenes.has(tmp_id):
				tmp_scene = tile_scenes[tmp_id]
				
				tmp_state = TileState.new(tmp_scene, tmp_id)
				tmp_state._add_to(tilemap, x, y)
				
				tile_array[tmp_index] = tmp_state
				
				if (tmp_state.flags & TileInfo.TileFlags.LIGHT_PASSES) == TileInfo.TileFlags.LIGHT_PASSES:
					shadow_array[tmp_index] = false
				else:
					shadow_array[tmp_index] = true
			else:
				shadow_array[tmp_index] = false
	map_image.unlock()
	
	_generate_shadows()
	
	emit_signal("map_loaded")

func _add_to_tileset(tile):
	var id = tile._get_id()
	
	if tile_scenes.has(id):
		return
	
	tileset.create_tile(id)
	tileset.tile_set_texture(id, tile.get_node("Sprite").texture)
	tileset.tile_set_region(id, tile.get_node("Sprite").region_rect)
	tileset.tile_set_z_index(id, tile.z_index)
	
	if not tile.get_node("Collider").disabled:
		tileset.tile_add_shape(id, tile.get_node("Collider").shape, tile.get_node("Collider").transform)
	
	tile_scenes[id] = tile

func _load_tiles():
	var file = ""
	var dir = Directory.new()
	for path in search_directories:
		if dir.open(path) != OK:
			continue
		dir.list_dir_begin()
		file = dir.get_next()
		while file != "":
			if file.ends_with(".tscn"):
				var tile = load(path + file).instance()
				if tile is TileInfo:
					_add_to_tileset(tile)
			
			file = dir.get_next()

func _generate_shadows():
	var shadow_texture = ImageTexture.new()
	var shadow_image = Image.new()
	
	shadow_image.create(map_width, map_height, true, Image.FORMAT_RGBAF)
	shadow_image.fill(Color(0, 0, 0, 1))
	
	shadow_image.lock()
	for x in range(map_width):
		for y in range(map_height):
			if shadow_array[x + y * map_width] == false:
				shadow_image.set_pixel(x, y, Color(0, 0, 0, 0))
	shadow_image.lock()
	
	shadow_texture.create_from_image(shadow_image)
	solid_shadow_layer.set_texture(shadow_texture)
	solid_shadow_layer.set_scale(Vector2(tile_size.x, tile_size.y))
	
	var material = solid_shadow_layer.get_material()
	material.set_shader_param("Step", Vector2(0.5/map_width, 0.5/map_height))
	material.set_shader_param("Step2", Vector2(0.5/map_width, -0.5/map_height))
	
	#scale(Vector2(8, 8))
	#var shadow_texture = ImageTexture.new()
	#shadow_texture.create(map_width, map_height, Image.FORMAT_RGB8, Texture.FLAG_FILTER)
	#solid_shadow_layer.set_texture(shadow_texture)