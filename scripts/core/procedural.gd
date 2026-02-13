extends TileMapLayer

@export var width := 200
@export var height := 50
@export var noise_scale := 0.05
@export var max_slope := 1

var noise := FastNoiseLite.new()

var players: Array[CharacterParent] = []

var surface_heights: Array[int] = []

func _ready():
	setup()

func setup():
	clear()
	surface_heights.clear()

	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = noise_scale

	var mid_y := (height / 2) - 15
	var last_y := mid_y

	for x in range(width):
		var n := noise.get_noise_1d(x)
		var raw_y := mid_y + int(n * 8.0)

		raw_y = clamp(raw_y, -15, height - 20)

		var delta := raw_y - last_y
		delta = clamp(delta, -1, 1)

		var tile_y := last_y + delta
		var tile_pos := Vector2i(x, tile_y)

		# --- SELECCIÓN DE TILE ---
		if delta == 0:
			var flat_tile := Vector2i(randi() % 4, 0)
			set_cell(tile_pos, 0, flat_tile)
			set_cell(tile_pos + Vector2i.DOWN, 0, Vector2i(4, 0))

		elif delta == -1:
			set_cell(tile_pos, 0, Vector2i(10, 0))
			set_cell(tile_pos + Vector2i.DOWN, 0, Vector2i(10, 1))

		elif delta == 1:
			tile_pos.y -= 1
			set_cell(tile_pos, 0, Vector2i(10, 0), 1)
			set_cell(tile_pos + Vector2i.DOWN, 0, Vector2i(10, 1), 1)

		last_y = tile_y
		surface_heights.append(tile_pos.y)

		# --- Relleno vertical ---
		var fill_start_y := tile_pos.y + 2
		for y in range(fill_start_y, height):
			var pos = Vector2i(x, y)
			if get_cell_source_id(pos) == -1:
				var value = [4, 9][randi() % 2]
				set_cell(pos, 0, Vector2i(value, 0))


	# ==============================
	# RELLENO LATERAL IZQUIERDO
	# ==============================
	var left_height = surface_heights[0]
	for x in range(-100, 0): # 10 columnas extra a la izquierda
		for y in range(-height, height):
			var pos = Vector2i(x, y)
			var value = [4, 9][randi() % 2]
			set_cell(pos, 0, Vector2i(value, 0))


	# ==============================
	# RELLENO LATERAL DERECHO
	# ==============================
	var right_height = surface_heights[width - 1]
	for x in range(width, width + 100): # 10 columnas extra a la derecha
		for y in range(-height, height):
			var pos = Vector2i(x, y)
			var value = [4, 9][randi() % 2]
			set_cell(pos, 0, Vector2i(value, 0))
