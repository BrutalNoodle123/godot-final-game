extends Node2D
@onready var tile_map_layer = $TileMapLayer
var rng = RandomNumberGenerator.new()

var floor_tile := Vector2i(2,3)
var wall_tile_bottom := Vector2i(0,1)
var wall_tile_top := Vector2i(8,0)
var wall_tile_right := Vector2i(1,1)

const WIDTH = 100
const HEIGHT = 100
const CELL_SIZE = 16
const MIN_ROOM_SIZE = 10
const MAX_ROOM_SIZE = 20
const MAX_ROOMS = 10


var grid = []
var rooms = []

func _ready():
		
	randomize()
	initialize_grid()
	generate_dungeon()
	generate_snake()
	generate_worm()
	generate_ghost()
	generate_mole()
	draw_dungeon()
	
func generate_snake():
	for i in range(3):
		var snake = load("res://character_1.tscn")
		var instance = snake.instantiate()
		var bounds = rooms[randi() % (rooms.size() - 1) + 1]	

		add_child(instance)
		print(instance.position)
		instance.scale = Vector2(0.2, 0.2)
		instance.position.x = rng.randf_range(bounds.position.x * CELL_SIZE, (bounds.position.x + bounds.size.x) * CELL_SIZE)
		instance.position.y = rng.randf_range(bounds.position.y * CELL_SIZE, (bounds.position.y + bounds.size.y) * CELL_SIZE)

func generate_worm():
	for i in range(2):
		var worm = load("res://character_2.tscn")
		var instance = worm.instantiate()
		
		var bounds = rooms[randi() % (rooms.size() - 1) + 1]	
		var padding = 1	
		print("worm")
		print(bounds)

		add_child(instance)
		print(instance.position)
		instance.scale = Vector2(0.2, 0.2)
		instance.position.x = rng.randf_range(bounds.position.x * CELL_SIZE, (bounds.position.x + bounds.size.x) * CELL_SIZE)
		instance.position.y = rng.randf_range(bounds.position.y * CELL_SIZE, (bounds.position.y + bounds.size.y) * CELL_SIZE)

func generate_ghost():
	for i in range(2):
		var ghost = load("res://character_3.tscn")
		var instance = ghost.instantiate()
		var bounds = rooms[randi() % (rooms.size() - 1) + 1]	

		add_child(instance)
		print(instance.position)
		instance.scale = Vector2(0.2, 0.2)
		instance.position.x = rng.randf_range(bounds.position.x * CELL_SIZE, (bounds.position.x + bounds.size.x) * CELL_SIZE)
		instance.position.y = rng.randf_range(bounds.position.y * CELL_SIZE, (bounds.position.y + bounds.size.y) * CELL_SIZE)
		
func generate_mole():
	for i in range(1):
		var mole = load("res://player.tscn")
		var instance = mole.instantiate()
	

		var bounds = rooms[0]
		var padding = 1

		add_child(instance)
		print(instance.position)
		instance.scale = Vector2(0.2, 0.2)

		instance.position.x = rng.randf_range(bounds.position.x * CELL_SIZE, (bounds.position.x + bounds.size.x) * CELL_SIZE)
		instance.position.y = rng.randf_range(bounds.position.y * CELL_SIZE, (bounds.position.y + bounds.size.y) * CELL_SIZE)
		print("mole")
		print(bounds)

func initialize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(1)

func generate_dungeon():
	for i in range(MAX_ROOMS):
		var room = generate_room()
		if place_room(room):
			if rooms.size() > 0:
				connect_rooms(rooms[-1], room)
			rooms.append(room)

func generate_room():
	var width = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var height = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var x = randi() % (WIDTH - width - 1) + 1
	var y = randi() % (HEIGHT - height - 1) + 1
	return Rect2(x, y, width, height)

func place_room(room):
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:
				return false
	
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0
	return true

func connect_rooms(room1, room2, corridor_width=3):
	var start = Vector2(
		int(room1.position.x + room1.size.x / 2),
		int(room1.position.y + room1.size.y / 2)
	)
	var end = Vector2(
		int(room2.position.x + room2.size.x / 2),
		int(room2.position.y + room2.size.y / 2)
	)
	
	var current = start
	
	while current.x != end.x:
		current.x += 1 if end.x > current.x else -1
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				if current.y + j >= 0 and current.y + j < HEIGHT and current.x + i >= 0 and current.x + i < WIDTH:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor

	while current.y != end.y:
		current.y += 1 if end.y > current.y else -1
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				if current.x + i >= 0 and current.x + i < WIDTH and current.y + j >= 0 and current.y + j < HEIGHT:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor

func draw_dungeon():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2i(x, y)
			if grid[x][y] == 0:
				tile_map_layer.set_cell(tile_position, 0, floor_tile)
			elif grid[x][y] == 1:
				if y < HEIGHT - 1 and grid[x][y + 1] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
					add_wall_collision(tile_position)  # Added this line for collision
				elif y > 0 and grid[x][y - 1] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_top)
					add_wall_collision(tile_position)  # Added this line for collision
				if x < WIDTH - 1 and grid[x+1][y] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
					add_wall_collision(tile_position)  # Added this line for collision
				elif x > 0 and grid[x-1][y] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_top)
					add_wall_collision(tile_position)  # Added this line for collision
				else:
					tile_map_layer.set_cell(tile_position, 0, Vector2i(-1, -1))
			else:
				tile_map_layer.set_cell(tile_position, 0, Vector2i(-1, -1))

func add_wall_collision(tile_position: Vector2i):
	var wall = StaticBody2D.new()
	var collision_shape = CollisionShape2D.new()

	var shape = RectangleShape2D.new()
	shape.extents = Vector2(CELL_SIZE / 2, CELL_SIZE / 2)  # Half the tile size for extents

	collision_shape.shape = shape
	wall.add_child(collision_shape)

	wall.position = tile_position * CELL_SIZE

	add_child(wall)
